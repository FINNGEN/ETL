# DESCRIPTION:
# Creates a row in cdm-drug exposure table for each FinnGen id in the PURCH registry.
# Person id is extracted from person table
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables


TRUNCATE TABLE @schema_cdm_output.drug_exposure;
INSERT INTO @schema_cdm_output.drug_exposure
(
  drug_exposure_id,
  person_id,
  drug_concept_id,
  drug_exposure_start_date,
  drug_exposure_start_datetime,
  drug_exposure_end_date,
  drug_exposure_end_datetime,
  verbatim_end_date,
  drug_type_concept_id,
  stop_reason,
  refills,
  quantity,
  days_supply,
  sig,
  route_concept_id,
  lot_number,
  provider_id,
  visit_occurrence_id,
  visit_detail_id,
  drug_source_value,
  drug_source_concept_id,
  route_source_value,
  dose_unit_source_value
)

WITH
# 1 - Get all purchase events form the PURCH registry
purchases_from_registers AS (
  SELECT *
  FROM(
    SELECT FINNGENID,
           SOURCE,
           APPROX_EVENT_DAY,
           CODE1_ATC_CODE AS CODE1,
           CODE3_VNRO AS CODE3,
           CODE4_PLKM AS CODE4,
           INDEX
    FROM @schema_etl_input.purch
  )
),
# 2 - Add vnr omop concept id
purchases_from_registers_vnr_info AS (
  SELECT pg.FINNGENID,
         pg.SOURCE,
         pg.APPROX_EVENT_DAY,
         pg.CODE1,
         pg.CODE3,
         pg.CODE4,
         pg.INDEX,
         fgc.omop_concept_id AS drug_omop_concept_id,
         fgc.name_en AS medicine_name
  FROM purchases_from_registers AS pg
  LEFT JOIN ( SELECT FG_CODE1,
                     omop_concept_id,
                     name_en
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'VNRfi') AS fgc
  ON fgc.FG_CODE1 = LPAD(pg.CODE3,6,'0')
),
# 3 - Add standard concept id and take the top priority
purchases_from_registers_vnr_info_standard_concept_id AS (
  SELECT prvi.*,
         drugmap.concept_id_2,
         RANK() OVER (PARTITION BY prvi.CODE3
                            ORDER BY CASE drugmap.concept_class_id
                                          WHEN 'Branded Pack' THEN 1
                                          WHEN 'Clinical Pack' THEN 2
                                          WHEN 'Branded Drug' THEN 3
                                          WHEN 'Clinical Drug' THEN 4
                                          WHEN 'Branded Drug Comp' THEN 5
                                          WHEN 'Clinical Drug Comp' THEN 6
                                          WHEN 'Branded Drug Form' THEN 7
                                          WHEN 'Clinical Drug Form' THEN 8
                                          WHEN 'Ingredient' THEN 9
                                          #WHEN 'Quant Clinical Drug' THEN 9
                                          #WHEN 'Quantified Branded Drug' THEN 10
                                          #WHEN 'Clinical Drug Box' THEN 11
                                          #WHEN 'Quantified Clinical Box' THEN 12
                                          #ELSE 13
                                          ELSE 10
                                     END
                           ) AS drug_priority
  FROM purchases_from_registers_vnr_info AS prvi
  LEFT JOIN (
    SELECT cr.concept_id_1,
           cr.concept_id_2,
           c.concept_class_id,
           c.concept_name
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id IN ('Drug')
  ) AS drugmap
  ON CAST(prvi.drug_omop_concept_id AS INT64) = drugmap.concept_id_1
)

# 4 - Shape into drug exposure table
SELECT
# drug_exposure_id
  ROW_NUMBER() OVER(ORDER by prvisci.SOURCE, prvisci.INDEX) AS drug_exposure_id,
# person_id
  p.person_id AS person_id,
# drug_concept_id
 CASE
     WHEN prvisci.concept_id_2 IS NOT NULL THEN prvisci.concept_id_2
		  ELSE 0
 END AS drug_concept_id,
# drug_exposure_start_date
  prvisci.APPROX_EVENT_DAY AS drug_exposure_start_date,
# drug_exposure_start_datetime
  DATETIME(TIMESTAMP(prvisci.APPROX_EVENT_DAY)) AS drug_exposure_start_datetime,
# drug_exposure_end_date
  prvisci.APPROX_EVENT_DAY AS drug_exposure_end_date,
# drug_exposure_end_datetime
  DATETIME(TIMESTAMP(prvisci.APPROX_EVENT_DAY)) AS drug_exposure_end_datetime,
# verbatim_end_date
  CAST(NULL AS DATE) AS verbatim_end_date,
# drug_type_concept_id
  32879 AS drug_type_concept_id,
# stop_reason
  CAST(NULL AS STRING) AS stop_reason,
# refills
  NULL AS refills,
# quantity
  CASE
      WHEN prvisci.CODE4 IS NOT NULL THEN CAST(prvisci.CODE4 AS FLOAT64)
      ELSE 0
  END AS quantity,
# days_supply
  1 AS days_supply,
# sig
  prvisci.medicine_name AS sig,
# route_concept_id
  NULL AS route_concept_id,
# lot_number
  CAST(NULL AS STRING) AS lot_number,
# provider_id
  vo.provider_id AS provider_id,
# visit_occurrence_id
  vo.visit_occurrence_id AS visit_occurrence_id,
# visit_detail_id
  NULL AS visit_detail_id,
# drug_source_value
  CASE
      WHEN SAFE_CAST(prvisci.CODE3 AS INT64) > 0 THEN LPAD(prvisci.CODE3,6,'0')
      ELSE prvisci.CODE3
  END AS drug_source_value,
# drug_source_concept_id
# CASE
#     WHEN prvisci.drug_omop_concept_id IS NOT NULL THEN CAST(prvisci.drug_omop_concept_id AS INT64)
#     ELSE 0
# END AS drug_source_concept_id,
  CAST(prvisci.drug_omop_concept_id AS INT64) AS drug_source_concept_id,
# route_source_value
  CAST(NULL AS STRING) AS route_source_value,
# dose_unit_source_value
  CAST(NULL AS STRING) AS dose_unit_source_value
FROM purchases_from_registers_vnr_info_standard_concept_id AS prvisci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = prvisci.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   CONCAT('SOURCE=',prvisci.SOURCE,';INDEX=',prvisci.INDEX) = vo.visit_source_value AND
   prvisci.APPROX_EVENT_DAY = vo.visit_start_date
WHERE prvisci.drug_priority = 1
ORDER BY p.person_id, prvisci.APPROX_EVENT_DAY;
