# DESCRIPTION:
# Creates a row in cdm.measurement table for each measurement event in the spirometry registry.
# Measurement columns - FEV1_BEST, FVC_BEST, FEV1_FVC_RATIO, FEV1_POST, FVC_POST, FEV1_FVC_POST, FEV1_CHANGE_PCT, FVC_CHANGE_PCT
# measurement_id is added by an offset of 121000000000
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
# 1- Process spirometry table to separate visit source
spirometry_processed AS (
  SELECT
      FINNGENID,
      APPROX_DATE AS APPROX_EVENT_DAY,
      CASE
          WHEN SOURCE = 'Auria Old Medikro' THEN 'AURIA_OLD_MEDIKRO'
          WHEN SOURCE = 'Auria New Medikro' THEN 'AURIA_NEW_MEDIKRO'
          WHEN SOURCE = 'Auria SentrySuite' THEN 'AURIA_SENTRYSUITE'
          WHEN SOURCE = 'Eastern Finland' THEN 'EASTERN_FINLAND'
          WHEN SOURCE = 'Borealis' THEN 'BOREALIS'
          WHEN SOURCE = 'Tampere' THEN 'TAMPERE'
          WHEN SOURCE = 'Helsinki' THEN 'HELSINKI'
          ELSE 'BIOBANK'
      END AS VISIT_SOURCE,
      FEV1_BEST,
      FVC_BEST,
      FEV1_FVC_RATIO,
      FEV1_POST,
      FVC_POST,
      FEV1_FVC_POST,
      FEV1_CHANGE_PCT,
      FVC_CHANGE_PCT
      FROM @schema_table_spirometry
),
# 2- Get measurments from the spirometry table
variables_from_spirometry AS (
# FEV1_BEST
  SELECT FINNGENID,
         'FEV1_BEST' AS SOURCE,
         APPROX_EVENT_DAY,
         CAST(NULL AS STRING) AS operator_value,
         FEV1_BEST AS measurement_value,
         'l' AS measurement_value_unit,
         CAST(NULL AS STRING) AS INDEX,
         VISIT_SOURCE
  FROM spirometry_processed AS sp
  WHERE FEV1_BEST IS NOT NULL
  UNION ALL
# FVC_BEST
  SELECT FINNGENID,
         'FVC_BEST' AS SOURCE,
         APPROX_EVENT_DAY,
         CAST(NULL AS STRING) AS operator_value,
         FVC_BEST AS measurement_value,
         'l' AS measurement_value_unit,
         CAST(NULL AS STRING) AS INDEX,
         VISIT_SOURCE
  FROM spirometry_processed AS sp
  WHERE FVC_BEST IS NOT NULL
  UNION ALL
# FEV1_FVC_RATIO
  SELECT FINNGENID,
         'FEV1_FVC_RATIO' AS SOURCE,
         APPROX_EVENT_DAY,
         CAST(NULL AS STRING) AS operator_value,
         FEV1_FVC_RATIO AS measurement_value,
         CAST(NULL AS STRING) AS measurement_value_unit,
         CAST(NULL AS STRING) AS INDEX,
         VISIT_SOURCE
  FROM spirometry_processed AS sp
  WHERE FEV1_FVC_RATIO IS NOT NULL
  UNION ALL
# FEV1_POST
  SELECT FINNGENID,
         'FEV1_POST' AS SOURCE,
         APPROX_EVENT_DAY,
         CAST(NULL AS STRING) AS operator_value,
         FEV1_POST AS measurement_value,
         'l' AS measurement_value_unit,
         CAST(NULL AS STRING) AS INDEX,
         VISIT_SOURCE
  FROM spirometry_processed AS sp
  WHERE FEV1_POST IS NOT NULL
  UNION ALL
# FVC_POST
  SELECT FINNGENID,
         'FVC_POST' AS SOURCE,
         APPROX_EVENT_DAY,
         CAST(NULL AS STRING) AS operator_value,
         FVC_POST AS measurement_value,
         'l' AS measurement_value_unit,
         CAST(NULL AS STRING) AS INDEX,
         VISIT_SOURCE
  FROM spirometry_processed AS sp
  WHERE FVC_POST IS NOT NULL
  UNION ALL
# FEV1_FVC_POST
  SELECT FINNGENID,
         'FEV1_FVC_POST' AS SOURCE,
         APPROX_EVENT_DAY,
         CAST(NULL AS STRING) AS operator_value,
         FEV1_FVC_POST AS measurement_value,
         CAST(NULL AS STRING) AS measurement_value_unit,
         CAST(NULL AS STRING) AS INDEX,
         VISIT_SOURCE
  FROM spirometry_processed AS sp
  WHERE FEV1_FVC_POST IS NOT NULL
  UNION ALL
# FEV1_CHANGE_PCT
  SELECT FINNGENID,
         'FEV1_CHANGE_PCT' AS SOURCE,
         APPROX_EVENT_DAY,
         CAST(NULL AS STRING) AS operator_value,
         FEV1_CHANGE_PCT AS measurement_value,
         CAST(NULL AS STRING) AS measurement_value_unit,
         CAST(NULL AS STRING) AS INDEX,
         VISIT_SOURCE
  FROM spirometry_processed AS sp
  WHERE FEV1_CHANGE_PCT IS NOT NULL
  UNION ALL
# FVC_CHANGE_PCT
  SELECT FINNGENID,
         'FVC_CHANGE_PCT' AS SOURCE,
         APPROX_EVENT_DAY,
         CAST(NULL AS STRING) AS operator_value,
         FVC_CHANGE_PCT AS measurement_value,
         CAST(NULL AS STRING) AS measurement_value_unit,
         CAST(NULL AS STRING) AS INDEX,
         VISIT_SOURCE
  FROM spirometry_processed AS sp
  WHERE FVC_CHANGE_PCT IS NOT NULL
),
# 3 - Add omop concept id to measurement_value and measurement_value_unit
variables_from_spirometry_omop_info AS (
  SELECT vfs.FINNGENID,
         vfs.SOURCE,
         vfs.APPROX_EVENT_DAY,
         vfs.operator_value,
         vfs.measurement_value,
         vfs.measurement_value_unit,
         vfs.INDEX,
         vfs.VISIT_SOURCE,
         fgc.omop_concept_id AS measurement_omop_concept_id,
         fgc.code,
         fgc1.omop_concept_id AS measurement_unit_omop_concept_id
  FROM (SELECT DISTINCT *
        FROM variables_from_spirometry
       ) AS vfs
  LEFT JOIN ( SELECT SOURCE,
                     code,
                     vocabulary_id,
                     omop_concept_id,
                     name_en
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'FGVisitType') AS fgc
  ON fgc.SOURCE = vfs.SOURCE
  LEFT JOIN ( SELECT code,
                     vocabulary_id,
                     omop_concept_id,
                     name_en
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'UNITfi') AS fgc1
  ON fgc1.code = vfs.measurement_value_unit
),
# 4 - Add standard concept id to measurement_value and measurement_value_unit
variables_from_spirometry_omop_info_standard_concept_id AS (
  SELECT vfsoi.FINNGENID,
         vfsoi.SOURCE,
         vfsoi.APPROX_EVENT_DAY,
         operatormap.concept_id AS operator_concept_id,
         vfsoi.measurement_value,
         vfsoi.measurement_value_unit,
         vfsoi.INDEX,
         vfsoi.VISIT_SOURCE,
         vfsoi.measurement_omop_concept_id,
         measurementmap.concept_id_2,
         vfsoi.code,
         vfsoi.measurement_unit_omop_concept_id,
         unitmap.concept_id_2 AS unit_concept_id
  FROM variables_from_spirometry_omop_info AS vfsoi
  LEFT JOIN (
    SELECT c.concept_id,
           c.concept_name
    FROM @schema_vocab.concept AS c
    WHERE c.domain_id IN ('Meas Value Operator')
  ) AS operatormap
  ON vfsoi.operator_value IS NOT DISTINCT FROM operatormap.concept_name
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
  ON CAST(vfsoi.measurement_omop_concept_id AS INT64) = measurementmap.concept_id_1
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
  ON CAST(vfsoi.measurement_unit_omop_concept_id AS INT64) = unitmap.concept_id_1
)
# 5 - Shape into measurement table
SELECT
# measurement_id
  ROW_NUMBER() OVER(ORDER by vfsoisci.FINNGENID) + 121000000000 AS measurement_id,
# person_id
  p.person_id AS person_id,
# measurement_concept_id
  CASE
      WHEN vfsoisci.concept_id_2 IS NOT NULL THEN vfsoisci.concept_id_2
      ELSE 0
  END AS measurement_concept_id,
# measurement_date
  vfsoisci.APPROX_EVENT_DAY AS measurement_date,
# measurement_datetime
  DATETIME(TIMESTAMP(vfsoisci.APPROX_EVENT_DAY)) AS measurement_datetime,
# measurement_time
  CAST(EXTRACT(TIME FROM DATETIME(TIMESTAMP(vfsoisci.APPROX_EVENT_DAY))) AS STRING) AS measurement_time,
# measurement_type_concept_id
  32879 AS measurement_type_concept_id,
# operator_concept_id
  CASE
    WHEN vfsoisci.operator_concept_id IS NOT NULL THEN vfsoisci.operator_concept_id
    ELSE 0
  END AS operator_concept_id,
# value_as_number
  SAFE_CAST(vfsoisci.measurement_value AS FLOAT64) AS value_as_number,
# value_as_concept_id
  0 AS value_as_concept_id,
# unit_concept_id
  CASE
    WHEN vfsoisci.unit_concept_id IS NOT NULL THEN vfsoisci.unit_concept_id
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
 vfsoisci.code AS measurement_source_value,
# measurement_source_concept_id
  CASE
    WHEN vfsoisci.measurement_omop_concept_id IS NOT NULL THEN CAST(vfsoisci.measurement_omop_concept_id AS INT64)
    ELSE 0
  END AS measurement_source_concept_id,
# unit_source_value
  vfsoisci.measurement_value_unit AS unit_source_value,
# unit_source_concept_id
  CASE
       WHEN vfsoisci.measurement_unit_omop_concept_id IS NOT NULL THEN CAST(vfsoisci.measurement_unit_omop_concept_id AS INT64)
       ELSE 0
  END AS unit_source_concept_id,
# value_source_value
  CAST(NULL AS STRING) AS value_source_value,
# measurement_event_id
  NULL AS measurement_event_id,
# meas_event_field_concept_id
  0 AS meas_event_field_concept_id
FROM variables_from_spirometry_omop_info_standard_concept_id AS vfsoisci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = vfsoisci.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   CONCAT('SOURCE=',vfsoisci.VISIT_SOURCE,';INDEX=') = vo.visit_source_value AND
   vfsoisci.APPROX_EVENT_DAY = vo.visit_start_date
ORDER BY person_id, measurement_id;
