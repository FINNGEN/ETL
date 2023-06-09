# DESCRIPTION:
# Creates a row in cdm-visit occurrence table for each event of FinnGen id in the birth mother.
# Person id is extracted from person table.
# visit_occurrence_id is added by an offset of 100000000000
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

INSERT INTO @schema_cdm_output.visit_occurrence
(
  visit_occurrence_id,
  person_id,
  visit_concept_id,
  visit_start_date,
  visit_start_datetime,
  visit_end_date,
  visit_end_datetime,
  visit_type_concept_id,
  provider_id,
  care_site_id,
  visit_source_value,
  visit_source_concept_id,
  admitted_from_concept_id,
  admitted_from_source_value,
  discharged_to_concept_id,
  discharged_to_source_value,
  preceding_visit_occurrence_id
)

WITH
# 1- Collect all child births from mother registry with necesary columns
visits_from_birth AS (
  SELECT
      MOTHER_FINNGENID AS FINNGENID,
      "BIRTH_MOTHER" AS SOURCE,
      APPROX_DELIVERY_DATE AS APPROX_EVENT_DAY,
      APPROX_DELIVERY_DATE AS approx_end_day,
      CAST(NULL AS STRING) AS CODE6,
      CAST(NULL AS STRING) AS CODE7
  FROM (
    SELECT ROW_NUMBER() OVER(PARTITION BY MOTHER_FINNGENID,APPROX_DELIVERY_DATE ORDER BY APPROX_DELIVERY_DATE DESC) AS q1,
           MOTHER_FINNGENID,
           APPROX_DELIVERY_DATE
    FROM (
      SELECT bm.MOTHER_FINNGENID,
             DATE_ADD( fi.APPROX_BIRTH_DATE, INTERVAL CAST(bm.MOTHER_AGE * 365.25 AS INT64) DAY ) AS APPROX_DELIVERY_DATE
      FROM @schema_table_birth_mother AS bm
      JOIN @schema_table_finngenid AS fi
      ON bm.MOTHER_FINNGENID = fi.FINNGENID
    )
  )
  WHERE q1 = 1
),

# 2- append visit type using script in FinnGenUtilsR
# 2-1 Process the visit codes to get visit_type from fg_codes_info_v3 table
visit_type_fg_codes_preprocessed AS (
  SELECT
    FINNGENID,
    SOURCE,
    APPROX_EVENT_DAY,
    approx_end_day,
    CODE6,
    CODE7,
    CAST(NULL AS STRING) AS FG_CODE5,
    CAST(NULL AS STRING) AS FG_CODE6,
    CAST(NULL AS STRING) AS FG_CODE8,
    CAST(NULL AS STRING) AS FG_CODE9
  FROM visits_from_birth
),
# 2-2 append visit type from fg_codes_info_v3 table with non-standard code
visits_from_registers_with_source_visit_type_id AS (
  SELECT vtfgpre.FINNGENID,
         vtfgpre.SOURCE,
         vtfgpre.APPROX_EVENT_DAY,
         vtfgpre.approx_end_day,
         vtfgpre.CODE6,
         vtfgpre.CODE7,
         fgc.omop_concept_id AS visit_type_omop_concept_id
  FROM visit_type_fg_codes_preprocessed AS vtfgpre
  LEFT JOIN ( SELECT SOURCE,
                     FG_CODE5,
                     FG_CODE6,
                     FG_CODE8,
                     FG_CODE9,
                     omop_concept_id
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'FGVisitType') AS fgc
  ON vtfgpre.SOURCE IS NOT DISTINCT FROM fgc.SOURCE AND
     vtfgpre.FG_CODE5 IS NOT DISTINCT FROM fgc.FG_CODE5 AND
     vtfgpre.FG_CODE6 IS NOT DISTINCT FROM fgc.FG_CODE6 AND
     vtfgpre.FG_CODE8 IS NOT DISTINCT FROM fgc.FG_CODE8 AND
     vtfgpre.FG_CODE9 IS NOT DISTINCT FROM fgc.FG_CODE9
),

# 3- add standard_visit_type_id
visits_from_registers_with_source_and_standard_visit_type_id AS (
  SELECT vfrwsvti.FINNGENID,
         vfrwsvti.SOURCE,
         vfrwsvti.APPROX_EVENT_DAY,
         vfrwsvti.approx_end_day,
         vfrwsvti.CODE6,
         vfrwsvti.CODE7,
         vfrwsvti.visit_type_omop_concept_id,
         ssmap.concept_id_2
  FROM visits_from_registers_with_source_visit_type_id AS vfrwsvti
  LEFT JOIN (
    SELECT cr.concept_id_1, cr.concept_id_2, c.concept_name
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id IN ('Visit','Metadata')
  ) AS ssmap
  ON
    CAST(vfrwsvti.visit_type_omop_concept_id AS INT64) = ssmap.concept_id_1
)
# 6- shaper into visit_occurrence_table
SELECT
# visit_occurrence_id
  ROW_NUMBER() OVER(ORDER BY vfrwssvtf.FINNGENID) + 100000000000 AS visit_occurrence_id,
#person_id,
  p.person_id AS person_id,
#visit_concept_id,
  CASE
    WHEN vfrwssvtf.concept_id_2 IS NOT NULL THEN vfrwssvtf.concept_id_2
    ELSE 0
  END AS visit_concept_id,
#visit_start_date,
  vfrwssvtf.APPROX_EVENT_DAY AS visit_start_date,
#visit_start_datetime,
  DATETIME(TIMESTAMP(vfrwssvtf.APPROX_EVENT_DAY)) AS visit_start_datetime,
#visit_end_date,
  vfrwssvtf.approx_end_day AS approx_end_day,
#visit_end_datetime,
  DATETIME(TIMESTAMP(vfrwssvtf.approx_end_day)) AS approx_end_day,
#visit_type_concept_id,
  32879 AS visit_type_concept_id,
#provider_id,
  provider.provider_id AS provider_id,
#care_site_id,
  NULL AS care_site_id,
#visit_source_value,
  CONCAT('SOURCE=',vfrwssvtf.SOURCE,';INDEX=') AS visit_source_value,
#visit_source_concept_id,
  CASE
    WHEN vfrwssvtf.visit_type_omop_concept_id IS NOT NULL THEN CAST(vfrwssvtf.visit_type_omop_concept_id AS INT64)
    ELSE 0
  END AS visit_source_concept_id,
#admitted_from_concept_id,
  0 AS admitted_from_concept_id,
#admitted_from_source_value,
  CAST(NULL AS STRING) AS admitted_from_source_value,
#discharged_to_concept_id,
  0 AS discharged_to_concept_id,
#discharged_to_source_value,
  CAST(NULL AS STRING) AS discharged_to_source_value,
#preceding_visit_occurrence_id
  NULL AS preceding_visit_occurrence_id
FROM visits_from_registers_with_source_and_standard_visit_type_id AS vfrwssvtf
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = vfrwssvtf.FINNGENID
LEFT JOIN ( SELECT FG_CODE6,
                   FG_CODE7,
                   omop_concept_id
            FROM @schema_table_codes_info
            WHERE vocabulary_id IN ('MEDSPECfi','ProfessionalCode')
          ) AS fgcp
ON CASE
        WHEN vfrwssvtf.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') THEN vfrwssvtf.CODE6 = fgcp.FG_CODE6
        WHEN vfrwssvtf.SOURCE = 'PRIM_OUT' THEN vfrwssvtf.CODE7 = fgcp.FG_CODE7
        ELSE NULL
   END
LEFT JOIN @schema_cdm_output.provider AS provider
ON CAST(fgcp.omop_concept_id AS INT64) = provider.specialty_source_concept_id
