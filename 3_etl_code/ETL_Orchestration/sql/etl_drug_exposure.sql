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
# 1 - Get all drug events
purchases_from_registers AS (
     SELECT *
     FROM (
     SELECT
     FINNGENID,
     CASE
           WHEN MERGED_SOURCE = 'KELA' THEN 'PURCH'
           ELSE MERGED_SOURCE
      END AS SOURCE,
     CASE
          WHEN MERGED_SOURCE != 'PRESCRIPTION' THEN MEDICATION_APPROX_EVENT_DAY
          ELSE PRESCRIPTION_APPROX_EVENT_DAY
     END AS APPROX_EVENT_DAY,
     CASE
          WHEN MERGED_SOURCE = 'PRESCRIPTION' THEN PRESCRIPTION_ATC
          WHEN MERGED_SOURCE = 'PRESCRIPTION_DELIVERY' AND MEDICATION_ATC IS NULL AND PRESCRIPTION_ATC IS NOT NULL THEN PRESCRIPTION_ATC
          WHEN MERGED_SOURCE = 'PRESCRIPTION_DELIVERY' AND MEDICATION_ATC IS NOT NULL THEN MEDICATION_ATC
          ELSE MEDICATION_ATC
     END AS CODE1,
     CASE
          WHEN MERGED_SOURCE = 'PRESCRIPTION' THEN PRESCRIPTION_VNR
          WHEN MERGED_SOURCE = 'PRESCRIPTION_DELIVERY' AND MEDICATION_VNR IS NULL AND PRESCRIPTION_VNR IS NOT NULL THEN PRESCRIPTION_VNR
          WHEN MERGED_SOURCE = 'PRESCRIPTION_DELIVERY' AND MEDICATION_VNR IS NOT NULL THEN MEDICATION_VNR
          ELSE MEDICATION_VNR
     END AS CODE3,
     MEDICATION_QUANTITY AS CODE4,
     CAST(NULL AS STRING) AS INDEX
     FROM @schema_drug_events
     )
),
# 2 - Calculate days supply
purchases_from_registers_days_supply AS (
     SELECT pg.FINNGENID,
            pg.SOURCE,
            pg.APPROX_EVENT_DAY,
            pg.CODE1,
            pg.CODE3,
            pg.CODE4,
            pg.INDEX,
            fv.DDDPerPack * SAFE_CAST(pg.CODE4 AS FLOAT64) AS days_supply
  FROM purchases_from_registers AS pg
  LEFT JOIN (SELECT DISTINCT VNR, DDDPerPack
             FROM @schema_table_finngen_vnr
            ) AS fv
  ON fv.VNR = SAFE_CAST(pg.CODE3 AS INT64)
),
# 3 - Add vnr omop concept id
purchases_from_registers_vnr_info AS (
  SELECT pgds.FINNGENID,
         pgds.SOURCE,
         pgds.APPROX_EVENT_DAY,
         pgds.CODE1,
         pgds.CODE3,
         pgds.CODE4,
         pgds.INDEX,
         pgds.days_supply,
         fgc.omop_concept_id AS drug_omop_concept_id,
         fgc.name_en AS medicine_name
  FROM purchases_from_registers_days_supply AS pgds
  LEFT JOIN ( SELECT FG_CODE1,
                     omop_concept_id,
                     name_en
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'VNRfi') AS fgc
  ON CAST(fgc.FG_CODE1 AS INT64) = SAFE_CAST(pgds.CODE3 AS INT64)
),
# 4 - Add standard concept id
purchases_from_registers_vnr_info_standard_concept_id AS (
  SELECT prvi.FINNGENID,
         prvi.SOURCE,
         prvi.APPROX_EVENT_DAY,
         prvi.CODE1,
         prvi.CODE3,
         prvi.CODE4,
         prvi.INDEX,
         prvi.days_supply,
         prvi.drug_omop_concept_id,
         prvi.medicine_name,
         drugmap.concept_id_2
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

# 5 - Shape into drug exposure table
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
  CASE
    WHEN prvisci.days_supply IS NOT NULL THEN DATE_ADD(prvisci.APPROX_EVENT_DAY, INTERVAL CAST(prvisci.days_supply + 1 AS INT64) DAY)
    ELSE prvisci.APPROX_EVENT_DAY
  END AS drug_exposure_end_date,
# drug_exposure_end_datetime
  CASE
    WHEN prvisci.days_supply IS NOT NULL THEN DATETIME(TIMESTAMP(DATE_ADD(prvisci.APPROX_EVENT_DAY, INTERVAL CAST(prvisci.days_supply + 1 AS INT64) DAY)))
    ELSE DATETIME(TIMESTAMP(prvisci.APPROX_EVENT_DAY))
  END AS drug_exposure_end_datetime,
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
  0 AS route_concept_id,
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
 CASE
     WHEN prvisci.drug_omop_concept_id IS NOT NULL THEN CAST(prvisci.drug_omop_concept_id AS INT64)
     ELSE 0
 END AS drug_source_concept_id,
# route_source_value
  CAST(NULL AS STRING) AS route_source_value,
# dose_unit_source_value
  CAST(NULL AS STRING) AS dose_unit_source_value
FROM purchases_from_registers_vnr_info_standard_concept_id AS prvisci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = prvisci.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   CONCAT('SOURCE=',prvisci.SOURCE,';INDEX=') = vo.visit_source_value AND
   prvisci.APPROX_EVENT_DAY = vo.visit_start_date
ORDER BY p.person_id, prvisci.APPROX_EVENT_DAY;
