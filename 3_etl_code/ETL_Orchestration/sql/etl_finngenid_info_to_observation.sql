# DESCRIPTION:
# Creates a row in cdm.observation table for each observation event in the cdm.finngenid_info.
# Finds zero or more standard code for each non-standard concept_id in cdm.finngenid_info.
# Checks Smoking columns in cdm.finngenid_info table and maps Smoking codes properly.
# Any row with SMOKE2 column value being NULL will be rejected.
# Insert resulting events into the cdm.observation table.
# observation_id is added by an offset of 112000000000
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

INSERT INTO @schema_cdm_output.observation
(
    observation_id,
    person_id,
    observation_concept_id,
    observation_date,
    observation_datetime,
    observation_type_concept_id,
    value_as_number,
    value_as_string,
    value_as_concept_id,
    qualifier_concept_id,
    unit_concept_id,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    observation_source_value,
    observation_source_concept_id,
    unit_source_value,
    qualifier_source_value,
    value_source_value,
    observation_event_id,
    obs_event_field_concept_id
)

WITH
# 1 - Get all Smoking values form the finngenid_info table for BIOBANK source
variables_from_biobank AS (
# SMOKING comes from three columns SMOKE2, SMOKE3 and SMOKE5
# SMOKE2 - contains 2 categories yes/no which are converted to 1/2
# SMOKE3 - contains 3 categories current/former/never which are converted to 1/2/3
# SMOKE5 - contains 5 categories current/occasional/quitter/former/never which are converted to 1/2/3/4/5
# SMOKING - only rows with SMOKE2 is not null are selected. SMOKE3 and SMOKE5 can be NULL
    SELECT *
    FROM(
      SELECT FINNGENID,
             'SMOKING' AS SOURCE,
             CASE
              WHEN APPROX_BIRTH_DATE IS NULL AND BL_YEAR IS NOT NULL THEN PARSE_DATE("%Y",CAST(BL_YEAR AS STRING))
              ELSE DATE_ADD( APPROX_BIRTH_DATE, INTERVAL CAST(BL_AGE * 365.25 AS INT64) DAY )
             END AS APPROX_EVENT_DAY,
             CASE
              WHEN SMOKE2 = 'yes' THEN '1'
              WHEN SMOKE2 = 'no' THEN '2'
              ELSE '0'
             END AS CODE1,
             CASE
              WHEN SMOKE3 = 'current' THEN '1'
              WHEN SMOKE3 = 'former' THEN '2'
              WHEN SMOKE3 = 'never' THEN '3'
              ELSE '0'
             END AS CODE2,
             CASE
              WHEN SMOKE5 = 'current' THEN '1'
              WHEN SMOKE5 = 'occasional' THEN '2'
              WHEN SMOKE5 = 'quitter' THEN '3'
              WHEN SMOKE5 = 'former' THEN '4'
              WHEN SMOKE5 = 'never' THEN '5'
              ELSE '0'
             END AS CODE3,
             CAST(NULL AS STRING) AS INDEX
      FROM @schema_etl_input.finngenid_info
      WHERE SMOKE2 IS NOT NULL
    )
),
# 2 - Add omop concept id
variables_from_biobank_omop_info AS (
  SELECT vfb.FINNGENID,
         vfb.SOURCE,
         vfb.APPROX_EVENT_DAY,
         vfb.CODE1,
         vfb.CODE2,
         vfb.CODE3,
         vfb.INDEX,
         fgc.omop_concept_id AS smoking_omop_concept_id,
         fgc.name_en,
         fgc.code
  FROM variables_from_biobank AS vfb
  LEFT JOIN ( SELECT SOURCE,
                     FG_CODE1,
                     FG_CODE2,
                     FG_CODE3,
                     code,
                     vocabulary_id,
                     omop_concept_id,
                     name_en
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'FGVisitType') AS fgc
  ON fgc.vocabulary_id = 'FGVisitType' AND
     fgc.FG_CODE1 = vfb.CODE1 AND
     fgc.FG_CODE2 = vfb.CODE2 AND
     fgc.FG_CODE3 = vfb.CODE3
),
# 3 - Add standard concept id
variables_from_biobank_omop_info_standard_concept_id AS (
  SELECT vfboi.FINNGENID,
         vfboi.SOURCE,
         vfboi.APPROX_EVENT_DAY,
         vfboi.CODE1,
         vfboi.CODE2,
         vfboi.CODE3,
         vfboi.INDEX,
         vfboi.smoking_omop_concept_id,
         vfboi.name_en,
         vfboi.code,
         smokingmap.concept_id_2
  FROM variables_from_biobank_omop_info AS vfboi
  LEFT JOIN (
    SELECT cr.concept_id_1,
           cr.concept_id_2,
           c.concept_class_id,
           c.concept_name
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id IN ('Observation')
  ) AS smokingmap
  ON CAST(vfboi.smoking_omop_concept_id AS INT64) = smokingmap.concept_id_1

)
# 4 - Shape into observation table
SELECT
# observation_id
  ROW_NUMBER() OVER(ORDER by vfboisci.FINNGENID) + 112000000000 AS observation_id,
# person_id
  p.person_id AS person_id,
# observation_concept_id
  CASE
      WHEN vfboisci.concept_id_2 IS NOT NULL THEN vfboisci.concept_id_2
      ELSE 0
  END AS observation_concept_id,
# observation_date
  vfboisci.APPROX_EVENT_DAY AS observation_date,
# observation_datetime
  DATETIME(TIMESTAMP(vfboisci.APPROX_EVENT_DAY)) AS observation_datetime,
# observation_type_concept_id
  32879 AS observation_type_concept_id,
# value_as_number
  NULL AS value_as_number,
# value_as_string
  vfboisci.name_en AS value_as_string,
# value_as_concept_id
  0 AS value_as_concept_id,
# qualifier_concept_id
  0 AS qualifier_concept_id,
# unit_concept_id
  0 AS unit_concept_id,
# provider_id
  vo.provider_id AS provider_id,
# visit_occurrence_id
  vo.visit_occurrence_id AS visit_occurrence_id,
# visit_detail_id
  NULL AS visit_detail_id,
# observation_source_value
  vfboisci.code AS observation_source_value,
# observation_source_concept_id
  CASE
    WHEN vfboisci.smoking_omop_concept_id IS NOT NULL THEN CAST(vfboisci.smoking_omop_concept_id AS INT64)
    ELSE 0
  END AS observation_source_concept_id,
# unit_source_value
  CAST(NULL AS STRING) AS unit_source_value,
# qualifier_source_value
  CAST(NULL AS STRING) AS qualifier_source_value,
# value_source_value
  CAST(NULL AS STRING) AS value_source_value,
# observation_event_id
  NULL AS observation_event_id,
# obs_event_field_concept_id
  0 AS obs_event_field_concept_id
FROM variables_from_biobank_omop_info_standard_concept_id AS vfboisci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = vfboisci.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   "SOURCE=BIOBANK;INDEX=" = vo.visit_source_value AND
   vfboisci.APPROX_EVENT_DAY = vo.visit_start_date
ORDER BY person_id, observation_id;
