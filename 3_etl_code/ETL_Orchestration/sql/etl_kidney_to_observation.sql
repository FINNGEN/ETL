# DESCRIPTION:
# Creates a row in cdm.observation table for each observation event in the cdm.kidney.
# Checks DIALYSIS_PER_WEEK in cdm.kidney table and maps dialysis observation codes properly.
# Uses DIALYSIS_PER_WEEK in combination with DIALYSIS_PER_WEEK in cdm.kidney to map to dialysis sessions per week standard code
# Checks PRODUCTION_OF_URINE, PERITONITIS_PER_YEAR in cdm.kidney table and maps dialysis observation codes properly.
# Insert resulting events into the cdm.observation table.
# observation_id is added by an offset of 115000000000
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
variables_from_kidney AS (
# DIALYSIS_PER_WEEK
  SELECT DISTINCT FINNGENID,
         'DIALYSIS_PER_WEEK' AS SOURCE,
         APPROX_EVENT_DAY,
         CAST(NULL AS STRING) AS CODE1,
         CAST(NULL AS STRING) AS CODE2,
         CAST(NULL AS STRING) AS CODE3,
         DIALYSIS_PER_WEEK AS CODE4,
         CAST(NULL AS STRING) AS UNIT,
         CAST(INDEX AS STRING) AS INDEX
  FROM (
    SELECT *,
           DENSE_RANK() OVER(ORDER BY FINNGENID, APPROX_VISIT_DATE) AS INDEX
    FROM (
      SELECT k.*,
           CASE
                WHEN k.APPROX_EVENT_DAY IS NULL THEN CAST(CONCAT(CAST(k.YEAR AS STRING),'-12-31') AS DATE)
                ELSE k.APPROX_EVENT_DAY
           END AS APPROX_VISIT_DATE
      FROM @schema_table_kidney AS k
    )
  )
  WHERE DIALYSIS_PER_WEEK IS NOT NULL
  UNION ALL
# DIALYSIS_PER_WEEK + DIALYSIS_PER_WEEK
# PRODUCTION_OF_URINE
  SELECT DISTINCT FINNGENID,
         'PRODUCTION_OF_URINE' AS SOURCE,
         APPROX_EVENT_DAY,
         CAST(NULL AS STRING) AS CODE1,
         CAST(NULL AS STRING) AS CODE2,
         CAST(NULL AS STRING) AS CODE3,
         PRODUCTION_OF_URINE AS CODE4,
         'ml' AS UNIT,
         CAST(INDEX AS STRING) AS INDEX
  FROM (
    SELECT *,
           DENSE_RANK() OVER(ORDER BY FINNGENID, APPROX_VISIT_DATE) AS INDEX
    FROM (
      SELECT k.*,
           CASE
                WHEN k.APPROX_EVENT_DAY IS NULL THEN CAST(CONCAT(CAST(k.YEAR AS STRING),'-12-31') AS DATE)
                ELSE k.APPROX_EVENT_DAY
           END AS APPROX_VISIT_DATE
      FROM @schema_table_kidney AS k
    )
  )
  WHERE PRODUCTION_OF_URINE IS NOT NULL
  UNION ALL
# PERITONITIS_PER_YEAR
  SELECT DISTINCT FINNGENID,
         'PERITONITIS_PER_YEAR' AS SOURCE,
         APPROX_EVENT_DAY,
         CAST(NULL AS STRING) AS CODE1,
         CAST(NULL AS STRING) AS CODE2,
         CAST(NULL AS STRING) AS CODE3,
         PERITONITIS_PER_YEAR AS CODE4,
         CAST(NULL AS STRING) AS UNIT,
         CAST(INDEX AS STRING) AS INDEX
  FROM (
    SELECT *,
           DENSE_RANK() OVER(ORDER BY FINNGENID, APPROX_VISIT_DATE) AS INDEX
    FROM (
      SELECT k.*,
           CASE
                WHEN k.APPROX_EVENT_DAY IS NULL THEN CAST(CONCAT(CAST(k.YEAR AS STRING),'-12-31') AS DATE)
                ELSE k.APPROX_EVENT_DAY
           END AS APPROX_VISIT_DATE
      FROM @schema_table_kidney AS k
    )
  )
  WHERE PERITONITIS_PER_YEAR IS NOT NULL
),
# 2 - Add omop concept id
variables_from_kidney_omop_info AS (
  SELECT vfk.FINNGENID,
         vfk.SOURCE,
         vfk.APPROX_EVENT_DAY,
         vfk.CODE1,
         vfk.CODE2,
         vfk.CODE3,
         vfk.CODE4,
         vfk.UNIT,
         vfk.INDEX,
         fgc.omop_concept_id AS variable_omop_concept_id,
         fgc.name_en,
         fgc.code,
         fgc1.omop_concept_id AS unit_omop_concept_id
  FROM variables_from_kidney AS vfk
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
  ON fgc.SOURCE = vfk.SOURCE AND
     fgc.FG_CODE1 IS NOT DISTINCT FROM vfk.CODE1 AND
     fgc.FG_CODE2 IS NOT DISTINCT FROM vfk.CODE2 AND
     fgc.FG_CODE3 IS NOT DISTINCT FROM vfk.CODE3
  LEFT JOIN ( SELECT code,
                     vocabulary_id,
                     omop_concept_id,
                     name_en
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'UNITfi_ALL') AS fgc1
  ON fgc1.code = vfk.UNIT
),
# 3 - Add standard concept id
variables_from_kidney_omop_info_standard_concept_id AS (
  SELECT vfkoi.FINNGENID,
         vfkoi.SOURCE,
         vfkoi.APPROX_EVENT_DAY,
         vfkoi.CODE1,
         vfkoi.CODE2,
         vfkoi.CODE3,
         vfkoi.CODE4,
         vfkoi.UNIT,
         vfkoi.INDEX,
         vfkoi.variable_omop_concept_id,
         vfkoi.unit_omop_concept_id,
         vfkoi.name_en,
         vfkoi.code,
         kvm.concept_id_2 AS variable_concept_id,
         uvm.concept_id_2 AS unit_concept_id
  FROM variables_from_kidney_omop_info AS vfkoi
  LEFT JOIN (
    SELECT cr.concept_id_1,
           cr.concept_id_2,
           c.concept_class_id,
           c.concept_name
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id IN ('Observation')
  ) AS kvm
  ON CAST(vfkoi.variable_omop_concept_id AS INT64) = kvm.concept_id_1
  LEFT JOIN (
    SELECT cr.concept_id_1,
           cr.concept_id_2,
           c.concept_class_id,
           c.concept_name
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id IN ('Unit')
  ) AS uvm
  ON CAST(vfkoi.unit_omop_concept_id AS INT64) = uvm.concept_id_1

)
# 4 - Shape into observation table
SELECT
# observation_id
  ROW_NUMBER() OVER(ORDER by vfkoisci.FINNGENID) + 115000000000 AS observation_id,
# person_id
  p.person_id AS person_id,
# observation_concept_id
  CASE
      WHEN vfkoisci.variable_concept_id IS NOT NULL THEN vfkoisci.variable_concept_id
      ELSE 0
  END AS observation_concept_id,
# observation_date
  vfkoisci.APPROX_EVENT_DAY AS observation_date,
# observation_datetime
  DATETIME(TIMESTAMP(vfkoisci.APPROX_EVENT_DAY)) AS observation_datetime,
# observation_type_concept_id
  32879 AS observation_type_concept_id,
# value_as_number
  vfkoisci.CODE4 AS value_as_number,
# value_as_string
  CAST(NULL AS STRING) AS value_as_string,
# value_as_concept_id
  0 AS value_as_concept_id,
# qualifier_concept_id
  0 AS qualifier_concept_id,
# unit_concept_id
  CASE
       WHEN vfkoisci.unit_concept_id IS NOT NULL THEN vfkoisci.unit_concept_id
       ELSE 0
  END AS unit_concept_id,
# provider_id
  vo.provider_id AS provider_id,
# visit_occurrence_id
  vo.visit_occurrence_id AS visit_occurrence_id,
# visit_detail_id
  NULL AS visit_detail_id,
# observation_source_value
  vfkoisci.code AS observation_source_value,
# observation_source_concept_id
  CASE
    WHEN vfkoisci.variable_omop_concept_id IS NOT NULL THEN CAST(vfkoisci.variable_omop_concept_id AS INT64)
    ELSE 0
  END AS observation_source_concept_id,
# unit_source_value
  vfkoisci.UNIT AS unit_source_value,
# qualifier_source_value
  CAST(NULL AS STRING) AS qualifier_source_value,
# value_source_value
  CAST(NULL AS STRING) AS value_source_value,
# observation_event_id
  NULL AS observation_event_id,
# obs_event_field_concept_id
  0 AS obs_event_field_concept_id
FROM variables_from_kidney_omop_info_standard_concept_id AS vfkoisci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = vfkoisci.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   CONCAT('SOURCE=KIDNEY;INDEX=',vfkoisci.INDEX) = vo.visit_source_value AND
   vfkoisci.APPROX_EVENT_DAY = vo.visit_start_date
ORDER BY person_id, observation_id;
