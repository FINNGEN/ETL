# DESCRIPTION:
# Creates a row in cdm.measurement table for each measurement event in the cdm.finngenid_info.
# Finds zero or more standard code for each non-standard concept_id in cdm.finngenid_info.
# Checks Height and Weight columns in cdm.finngenid_info table and calculates BMI only when both Height and Weight are not NULL.
# If Weight is NULL then only Height is selected with default unit "cm"
# Insert resulting events into the cdm.measurement table.
# measurement_id is added by an offset of 111000000000
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

INSERT INTO @schema_cdm_output.measurement
(
    measurement_id,
    person_id,
    measurement_concept_id,
    measurement_date,
    measurement_datetime,
    measurement_time,
    measurement_type_concept_id,
    operator_concept_id,
    value_as_number,
    value_as_concept_id,
    unit_concept_id,
    range_low,
    range_high,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    measurement_source_value,
    measurement_source_concept_id,
    unit_source_value,
    unit_source_concept_id,
    value_source_value,
    measurement_event_id,
    meas_event_field_concept_id
)

WITH
# 1 - Get all Height and Weight values form the finngenid_info table for BIOBANK source
variables_from_biobank AS (
# BMI - Only the rows with both Height and Weight not NULL are selected
  SELECT *
  FROM(
    SELECT FINNGENID,
           'BMI' AS SOURCE,
           CASE
            WHEN APPROX_BIRTH_DATE IS NULL AND BL_YEAR IS NOT NULL THEN PARSE_DATE("%Y",CAST(BL_YEAR AS STRING))
            ELSE DATE_ADD( APPROX_BIRTH_DATE, INTERVAL CAST(BL_AGE * 365.25 AS INT64) DAY )
           END AS APPROX_EVENT_DAY,
           CAST(ROUND((WEIGHT / ((HEIGHT/100) * (HEIGHT/100))),2) AS STRING) AS measurement_value,
           CAST(NULL AS STRING) AS measurement_value_unit,
           CAST(NULL AS STRING) AS INDEX
    FROM @schema_etl_input.finngenid_info
    WHERE HEIGHT IS NOT NULL AND WEIGHT IS NOT NULL
  )
  UNION ALL
# HEIGHT - Only the rows with Height not NULL are selected
  SELECT *
  FROM(
    SELECT FINNGENID,
           'HEIGHT' AS SOURCE,
           CASE
            WHEN APPROX_BIRTH_DATE IS NULL AND BL_YEAR IS NOT NULL THEN PARSE_DATE("%Y",CAST(BL_YEAR AS STRING))
            ELSE DATE_ADD( APPROX_BIRTH_DATE, INTERVAL CAST(BL_AGE * 365.25 AS INT64) DAY )
           END AS APPROX_EVENT_DAY,
           CAST(HEIGHT AS STRING) AS measurement_value,
           'cm' AS measurement_value_unit,
           CAST(NULL AS STRING) AS INDEX
    FROM @schema_etl_input.finngenid_info
    WHERE HEIGHT IS NOT NULL
  )
),
# 2 - Add omop concept id to measurement_value and measurement_value_unit
variables_from_biobank_omop_info AS (
  SELECT vfb.FINNGENID,
         vfb.SOURCE,
         vfb.APPROX_EVENT_DAY,
         vfb.measurement_value,
         vfb.measurement_value_unit,
         vfb.INDEX,
         fgc.omop_concept_id AS measurement_omop_concept_id,
         unitmap.concept_id AS measurement_unit_omop_concept_id
  FROM variables_from_biobank AS vfb
  LEFT JOIN ( SELECT SOURCE,
                     vocabulary_id,
                     omop_concept_id,
                     name_en
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'FGVisitType') AS fgc
  ON fgc.SOURCE = vfb.SOURCE AND fgc.vocabulary_id = 'FGVisitType'
  LEFT JOIN ( SELECT concept_id, concept_code
              FROM @schema_vocab.concept
              WHERE vocabulary_id = 'UNITfi_ALL') AS unitmap
  ON unitmap.concept_code = vfb.measurement_value_unit
),
# 3 - Add standard concept id to measurement_value and measurement_value_unit
variables_from_biobank_omop_info_standard_concept_id AS (
  SELECT vfboi.FINNGENID,
         vfboi.SOURCE,
         vfboi.APPROX_EVENT_DAY,
         vfboi.measurement_value,
         vfboi.measurement_value_unit,
         vfboi.INDEX,
         vfboi.measurement_omop_concept_id,
         measurementmap.concept_id_2,
         vfboi.measurement_unit_omop_concept_id,
         unitmap.concept_id_2 AS unit_concept_id
  FROM variables_from_biobank_omop_info AS vfboi
  LEFT JOIN (
    SELECT cr.concept_id_1,
           cr.concept_id_2,
           c.concept_class_id,
           c.concept_name
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id IN ('Measurement')
  ) AS measurementmap
  ON CAST(vfboi.measurement_omop_concept_id AS INT64) = measurementmap.concept_id_1
  LEFT JOIN (
    SELECT cr.concept_id_1,
           cr.concept_id_2,
           c.concept_class_id,
           c.concept_name
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id IN ('Unit')
  ) AS unitmap
  ON vfboi.measurement_unit_omop_concept_id = unitmap.concept_id_1
)
# 4 - Shape into measurement table
SELECT
# measurement_id
  ROW_NUMBER() OVER(ORDER by vfboisci.FINNGENID) + 111000000000 AS measurement_id,
# person_id
  p.person_id AS person_id,
# measurement_concept_id
  CASE
      WHEN vfboisci.concept_id_2 IS NOT NULL THEN vfboisci.concept_id_2
      ELSE 0
  END AS measurement_concept_id,
# measurement_date
  vfboisci.APPROX_EVENT_DAY AS measurement_date,
# measurement_datetime
  DATETIME(TIMESTAMP(vfboisci.APPROX_EVENT_DAY)) AS measurement_datetime,
# measurement_time
  CAST(EXTRACT(TIME FROM DATETIME(TIMESTAMP(vfboisci.APPROX_EVENT_DAY))) AS STRING) AS measurement_time,
# measurement_type_concept_id
  32879 AS measurement_type_concept_id,
# operator_concept_id
  0 AS operator_concept_id,
# value_as_number
  SAFE_CAST(vfboisci.measurement_value AS FLOAT64) AS value_as_number,
# value_as_concept_id
  0 AS value_as_concept_id,
# unit_concept_id
  CASE
    WHEN vfboisci.unit_concept_id IS NOT NULL THEN vfboisci.unit_concept_id
    ELSE 0
  END AS unit_concept_id,
# range_low
  NULL AS range_low,
# range_high
  NULL AS range_high,
# provider_id
  vo.provider_id AS provider_id,
# visit_occurrence_id
  vo.visit_occurrence_id AS visit_occurrence_id,
# visit_detail_id
  NULL AS visit_detail_id,
# measurement_source_value
 vfboisci.SOURCE AS measurement_source_value,
# measurement_source_concept_id
  CASE
    WHEN vfboisci.measurement_omop_concept_id IS NOT NULL THEN CAST(vfboisci.measurement_omop_concept_id AS INT64)
    ELSE 0
  END AS measurement_source_concept_id,
# unit_source_value
  vfboisci.measurement_value_unit AS unit_source_value,
# unit_source_concept_id
  CASE
       WHEN vfboisci.measurement_unit_omop_concept_id IS NOT NULL THEN vfboisci.measurement_unit_omop_concept_id
       ELSE 0
  END AS unit_source_concept_id,
# value_source_value
  CAST(NULL AS STRING) AS value_source_value,
# measurement_event_id
  NULL AS measurement_event_id,
# meas_event_field_concept_id
  0 AS meas_event_field_concept_id
FROM variables_from_biobank_omop_info_standard_concept_id AS vfboisci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = vfboisci.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   "SOURCE=BIOBANK;INDEX=" = vo.visit_source_value AND
   vfboisci.APPROX_EVENT_DAY = vo.visit_start_date
ORDER BY person_id, measurement_id;
