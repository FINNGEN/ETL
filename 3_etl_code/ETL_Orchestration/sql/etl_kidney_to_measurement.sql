# DESCRIPTION:
# Creates a row in cdm.measurement table for each measurement event in the kidney registry.
# Measurement columns - SYSTOLIC_BLOOD_PRESSURE, DIASTOLIC_BLOOD_PRESSURE, CHOLESTEROL, HDL_CHOLESTEROL, TRIGLYCERIDE
# measurement_id is added by an offset of 116000000000
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
# 1- Get measurments from the kidney table
variables_from_kidney AS (
# SYSTOLIC_BLOOD_PRESSURE
  SELECT FINNGENID,
         'SYSTOLIC_BLOOD_PRESSURE' AS SOURCE,
         APPROX_EVENT_DAY,
         CAST(NULL AS STRING) AS operator_value,
         SYSTOLIC_BLOOD_PRESSURE AS measurement_value,
         CAST(NULL AS STRING) AS measurement_value_unit,
         INDEX
  FROM (
    SELECT DISTINCT *,
           ROW_NUMBER() OVER(ORDER BY FINNGENID) AS INDEX
    FROM (
      SELECT *
      FROM @schema_table_kidney
      WHERE APPROX_EVENT_DAY IS NOT NULL
      UNION ALL
      SELECT FINNGENID, EVENT_AGE,
             SAFE_CAST(CONCAT(SAFE_CAST(YEAR AS STRING),'-12-31') AS DATE) AS APPROX_EVENT_DAY,
             *EXCEPT(FINNGENID, EVENT_AGE, APPROX_EVENT_DAY)
      FROM @schema_table_kidney
      WHERE APPROX_EVENT_DAY IS NULL
    )
  )
  WHERE SYSTOLIC_BLOOD_PRESSURE IS NOT NULL
  UNION ALL
# DIASTOLIC_BLOOD_PRESSURE
  SELECT FINNGENID,
         'DIASTOLIC_BLOOD_PRESSURE' AS SOURCE,
         APPROX_EVENT_DAY,
         CAST(NULL AS STRING) AS operator_value,
         DIASTOLIC_BLOOD_PRESSURE AS measurement_value,
         CAST(NULL AS STRING) AS measurement_value_unit,
         INDEX
  FROM (
    SELECT DISTINCT *,
           ROW_NUMBER() OVER(ORDER BY FINNGENID) AS INDEX
    FROM (
      SELECT *
      FROM @schema_table_kidney
      WHERE APPROX_EVENT_DAY IS NOT NULL
      UNION ALL
      SELECT FINNGENID, EVENT_AGE,
             SAFE_CAST(CONCAT(SAFE_CAST(YEAR AS STRING),'-12-31') AS DATE) AS APPROX_EVENT_DAY,
             *EXCEPT(FINNGENID, EVENT_AGE, APPROX_EVENT_DAY)
      FROM @schema_table_kidney
      WHERE APPROX_EVENT_DAY IS NULL
    )
  )
  WHERE DIASTOLIC_BLOOD_PRESSURE IS NOT NULL
  UNION ALL
# CHOLESTEROL
  SELECT FINNGENID,
         'CHOLESTEROL' AS SOURCE,
         APPROX_EVENT_DAY,
         CAST(NULL AS STRING) AS operator_value,
         CHOLESTEROL AS measurement_value,
         'mmol/l' AS measurement_value_unit,
         INDEX
  FROM (
    SELECT DISTINCT *,
           ROW_NUMBER() OVER(ORDER BY FINNGENID) AS INDEX
    FROM (
      SELECT *
      FROM @schema_table_kidney
      WHERE APPROX_EVENT_DAY IS NOT NULL
      UNION ALL
      SELECT FINNGENID, EVENT_AGE,
             SAFE_CAST(CONCAT(SAFE_CAST(YEAR AS STRING),'-12-31') AS DATE) AS APPROX_EVENT_DAY,
             *EXCEPT(FINNGENID, EVENT_AGE, APPROX_EVENT_DAY)
      FROM @schema_table_kidney
      WHERE APPROX_EVENT_DAY IS NULL
    )
  )
  WHERE CHOLESTEROL IS NOT NULL
  UNION ALL
# HDL_CHOLESTEROL
  SELECT FINNGENID,
         'HDL_CHOLESTEROL' AS SOURCE,
         APPROX_EVENT_DAY,
         CAST(NULL AS STRING) AS operator_value,
         HDL_CHOLESTEROL AS measurement_value,
         'mmol/l' AS measurement_value_unit,
         INDEX
  FROM (
    SELECT DISTINCT *,
           ROW_NUMBER() OVER(ORDER BY FINNGENID) AS INDEX
    FROM (
      SELECT *
      FROM @schema_table_kidney
      WHERE APPROX_EVENT_DAY IS NOT NULL
      UNION ALL
      SELECT FINNGENID, EVENT_AGE,
             SAFE_CAST(CONCAT(SAFE_CAST(YEAR AS STRING),'-12-31') AS DATE) AS APPROX_EVENT_DAY,
             *EXCEPT(FINNGENID, EVENT_AGE, APPROX_EVENT_DAY)
      FROM @schema_table_kidney
      WHERE APPROX_EVENT_DAY IS NULL
    )
  )
  WHERE HDL_CHOLESTEROL IS NOT NULL
  UNION ALL
# TRIGLYCERIDE
  SELECT FINNGENID,
         'TRIGLYCERIDE' AS SOURCE,
         APPROX_EVENT_DAY,
         CAST(NULL AS STRING) AS operator_value,
         TRIGLYCERIDE AS measurement_value,
         'mmol/l' AS measurement_value_unit,
         INDEX
  FROM (
    SELECT DISTINCT *,
           ROW_NUMBER() OVER(ORDER BY FINNGENID) AS INDEX
    FROM (
      SELECT *
      FROM @schema_table_kidney
      WHERE APPROX_EVENT_DAY IS NOT NULL
      UNION ALL
      SELECT FINNGENID, EVENT_AGE,
             SAFE_CAST(CONCAT(SAFE_CAST(YEAR AS STRING),'-12-31') AS DATE) AS APPROX_EVENT_DAY,
             *EXCEPT(FINNGENID, EVENT_AGE, APPROX_EVENT_DAY)
      FROM @schema_table_kidney
      WHERE APPROX_EVENT_DAY IS NULL
    )
  )
  WHERE TRIGLYCERIDE IS NOT NULL
),
# 2 - Add omop concept id to measurement_value and measurement_value_unit
variables_from_kidney_omop_info AS (
  SELECT vfk.FINNGENID,
         vfk.SOURCE,
         vfk.APPROX_EVENT_DAY,
         vfk.operator_value,
         vfk.measurement_value,
         vfk.measurement_value_unit,
         vfk.INDEX,
         fgc.omop_concept_id AS measurement_omop_concept_id,
         fgc.code,
         fgc1.omop_concept_id AS measurement_unit_omop_concept_id
  FROM variables_from_kidney AS vfk
  LEFT JOIN ( SELECT SOURCE,
                     code,
                     vocabulary_id,
                     omop_concept_id,
                     name_en
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'FGVisitType') AS fgc
  ON fgc.SOURCE = vfk.SOURCE
  LEFT JOIN ( SELECT code,
                     vocabulary_id,
                     omop_concept_id,
                     name_en
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'UNITfi_ALL') AS fgc1
  ON fgc1.code = vfk.measurement_value_unit
),
# 3 - Add standard concept id to measurement_value and measurement_value_unit
variables_from_kidney_omop_info_standard_concept_id AS (
  SELECT vfkoi.FINNGENID,
         vfkoi.SOURCE,
         vfkoi.APPROX_EVENT_DAY,
         operatormap.concept_id AS operator_concept_id,
         vfkoi.measurement_value,
         vfkoi.measurement_value_unit,
         vfkoi.INDEX,
         vfkoi.measurement_omop_concept_id,
         measurementmap.concept_id_2,
         vfkoi.code,
         vfkoi.measurement_unit_omop_concept_id,
         unitmap.concept_id_2 AS unit_concept_id
  FROM variables_from_kidney_omop_info AS vfkoi
  LEFT JOIN (
    SELECT c.concept_id,
           c.concept_name
    FROM @schema_vocab.concept AS c
    WHERE c.domain_id IN ('Meas Value Operator')
  ) AS operatormap
  ON vfkoi.operator_value IS NOT DISTINCT FROM operatormap.concept_name
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
  ON CAST(vfkoi.measurement_omop_concept_id AS INT64) = measurementmap.concept_id_1
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
  ON CAST(vfkoi.measurement_unit_omop_concept_id AS INT64) = unitmap.concept_id_1
)
# 4 - Shape into measurement table
SELECT
# measurement_id
  ROW_NUMBER() OVER(ORDER by vfkoisci.FINNGENID) + 116000000000 AS measurement_id,
# person_id
  p.person_id AS person_id,
# measurement_concept_id
  CASE
      WHEN vfkoisci.concept_id_2 IS NOT NULL THEN vfkoisci.concept_id_2
      ELSE 0
  END AS measurement_concept_id,
# measurement_date
  vfkoisci.APPROX_EVENT_DAY AS measurement_date,
# measurement_datetime
  DATETIME(TIMESTAMP(vfkoisci.APPROX_EVENT_DAY)) AS measurement_datetime,
# measurement_time
  CAST(EXTRACT(TIME FROM DATETIME(TIMESTAMP(vfkoisci.APPROX_EVENT_DAY))) AS STRING) AS measurement_time,
# measurement_type_concept_id
  32879 AS measurement_type_concept_id,
# operator_concept_id
  CASE
    WHEN vfkoisci.operator_concept_id IS NOT NULL THEN vfkoisci.operator_concept_id
    ELSE 0
  END AS operator_concept_id,
# value_as_number
  SAFE_CAST(vfkoisci.measurement_value AS FLOAT64) AS value_as_number,
# value_as_concept_id
  0 AS value_as_concept_id,
# unit_concept_id
  CASE
    WHEN vfkoisci.unit_concept_id IS NOT NULL THEN vfkoisci.unit_concept_id
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
 vfkoisci.code AS measurement_source_value,
# measurement_source_concept_id
  CASE
    WHEN vfkoisci.measurement_omop_concept_id IS NOT NULL THEN CAST(vfkoisci.measurement_omop_concept_id AS INT64)
    ELSE 0
  END AS measurement_source_concept_id,
# unit_source_value
  vfkoisci.measurement_value_unit AS unit_source_value,
# unit_source_concept_id
  CASE
       WHEN vfkoisci.measurement_unit_omop_concept_id IS NOT NULL THEN vfkoisci.measurement_unit_omop_concept_id
       ELSE 0
  END AS unit_source_concept_id,
# value_source_value
  CAST(NULL AS STRING) AS value_source_value,
# measurement_event_id
  NULL AS measurement_event_id,
# meas_event_field_concept_id
  0 AS meas_event_field_concept_id
FROM variables_from_kidney_omop_info_standard_concept_id AS vfkoisci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = vfkoisci.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   CONCAT('SOURCE=KIDNEY;INDEX=',vfkoisci.INDEX) = vo.visit_source_value AND
   vfkoisci.APPROX_EVENT_DAY = vo.visit_start_date
ORDER BY person_id, measurement_id;
