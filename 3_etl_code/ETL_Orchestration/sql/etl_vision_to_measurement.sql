# DESCRIPTION:
# Creates a row in cdm.measurement table for each measurement event in the vision registry.
# Visual field diameter measurment for either right eye or left eye or both is captured.
# SQL skips any row with both visual field diameter columns (OHALK and VHALK) missing
# Degree non-standard concept id for unit is taken from SNOMED Unit domain with name `degrees of arc`
# measurement_id is added by an offset of 114000000000
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
# 1- Get all visual field measurments from the vision table for VISION source
# 1-1 Visual field diameter for right eye from column OHALK
# 1-2 Visual field diameter for left eye from column VHALK
variables_from_vision AS (
# VFDRE - Visual field diameter right eye
  SELECT FINNGENID,
         'VFDRE' AS SOURCE,
         APPROX_VISIT_DATE AS APPROX_EVENT_DAY,
         CASE
          WHEN OHALK = 1 THEN '='
          WHEN OHALK IN (2,3,4,5) THEN '<='
          ELSE '>'
         END AS operator_value,
         CASE
          WHEN OHALK = 1 THEN 0
          WHEN OHALK = 2 THEN 5
          WHEN OHALK = 3 THEN 10
          WHEN OHALK = 4 THEN 20
          ELSE 60
         END AS measurement_value,
         'degrees of arc' AS measurement_value_unit,
         CAST(NULL AS STRING) AS INDEX
  FROM (
    SELECT vi.FINNGENID,
           DATE_ADD( fi.APPROX_BIRTH_DATE, INTERVAL CAST(vi.EVENT_AGE * 365.25 AS INT64) DAY ) AS APPROX_VISIT_DATE,
           vi.OHALK
    FROM (
      SELECT FINNGENID,
             EVENT_AGE,
             OHALK,
             ROW_NUMBER() OVER(PARTITION BY FINNGENID,CAST(EVENT_AGE AS STRING) ORDER BY DIAGN1, DIAGN2 NULLS LAST, DIAGN3 NULLS LAST, DIAGN4 NULLS LAST ) AS q1
      FROM @schema_table_vision
      WHERE EVENT_AGE > 0
    ) AS vi
    JOIN @schema_table_finngenid AS fi
    ON vi.FINNGENID = fi.FINNGENID
    WHERE q1 = 1 AND vi.OHALK IS NOT NULL
  )
  UNION ALL
# VFDLE - Visual field diameter left eye
  SELECT FINNGENID,
         'VFDLE' AS SOURCE,
         APPROX_VISIT_DATE AS APPROX_EVENT_DAY,
         CASE
          WHEN VHALK = 1 THEN '='
          WHEN VHALK IN (2,3,4,5) THEN '<='
          ELSE '>'
         END AS operator_value,
         CASE
          WHEN VHALK = 1 THEN 0
          WHEN VHALK = 2 THEN 5
          WHEN VHALK = 3 THEN 10
          WHEN VHALK = 4 THEN 20
          ELSE 60
         END AS measurement_value,
         'degrees of arc' AS measurement_value_unit,
         CAST(NULL AS STRING) AS INDEX
  FROM (
    SELECT vi.FINNGENID,
           DATE_ADD( fi.APPROX_BIRTH_DATE, INTERVAL CAST(vi.EVENT_AGE * 365.25 AS INT64) DAY ) AS APPROX_VISIT_DATE,
           vi.VHALK
    FROM (
      SELECT FINNGENID,
             EVENT_AGE,
             VHALK,
             ROW_NUMBER() OVER(PARTITION BY FINNGENID,CAST(EVENT_AGE AS STRING) ORDER BY DIAGN1, DIAGN2 NULLS LAST, DIAGN3 NULLS LAST, DIAGN4 NULLS LAST ) AS q1
      FROM @schema_table_vision
      WHERE EVENT_AGE > 0
    ) AS vi
    JOIN @schema_table_finngenid AS fi
    ON vi.FINNGENID = fi.FINNGENID
    WHERE q1 = 1 AND vi.VHALK IS NOT NULL
  )
),
# 2 - Add omop concept id to measurement_value and measurement_value_unit
variables_from_vision_omop_info AS (
  SELECT vfv.FINNGENID,
         vfv.SOURCE,
         vfv.APPROX_EVENT_DAY,
         vfv.operator_value,
         vfv.measurement_value,
         vfv.measurement_value_unit,
         vfv.INDEX,
         fgc.omop_concept_id AS measurement_omop_concept_id,
         unitmap.concept_id AS measurement_unit_omop_concept_id
  FROM variables_from_vision AS vfv
  LEFT JOIN ( SELECT SOURCE,
                     vocabulary_id,
                     omop_concept_id,
                     name_en
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'FGVisitType') AS fgc
  ON fgc.SOURCE = vfv.SOURCE AND fgc.vocabulary_id = 'FGVisitType'
  LEFT JOIN ( SELECT concept_id, concept_name
              FROM @schema_vocab.concept
              WHERE vocabulary_id = 'SNOMED' AND domain_id = 'Unit') AS unitmap
  ON unitmap.concept_name = vfv.measurement_value_unit
),
# 3 - Add standard concept id to measurement_value and measurement_value_unit
variables_from_vision_omop_info_standard_concept_id AS (
  SELECT vfvoi.FINNGENID,
         vfvoi.SOURCE,
         vfvoi.APPROX_EVENT_DAY,
         operatormap.concept_id AS operator_concept_id,
         vfvoi.measurement_value,
         vfvoi.measurement_value_unit,
         vfvoi.INDEX,
         vfvoi.measurement_omop_concept_id,
         measurementmap.concept_id_2,
         vfvoi.measurement_unit_omop_concept_id,
         unitmap.concept_id_2 AS unit_concept_id
  FROM variables_from_vision_omop_info AS vfvoi
  LEFT JOIN (
    SELECT c.concept_id,
           c.concept_name
    FROM @schema_vocab.concept AS c
    WHERE c.domain_id IN ('Meas Value Operator')
  ) AS operatormap
  ON vfvoi.operator_value = operatormap.concept_name
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
  ON CAST(vfvoi.measurement_omop_concept_id AS INT64) = measurementmap.concept_id_1
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
  ON vfvoi.measurement_unit_omop_concept_id = unitmap.concept_id_1
)
# 4 - Shape into measurement table
SELECT
# measurement_id
  ROW_NUMBER() OVER(ORDER by vfvoisci.FINNGENID) + 114000000000 AS measurement_id,
# person_id
  p.person_id AS person_id,
# measurement_concept_id
  CASE
      WHEN vfvoisci.concept_id_2 IS NOT NULL THEN vfvoisci.concept_id_2
      ELSE 0
  END AS measurement_concept_id,
# measurement_date
  vfvoisci.APPROX_EVENT_DAY AS measurement_date,
# measurement_datetime
  DATETIME(TIMESTAMP(vfvoisci.APPROX_EVENT_DAY)) AS measurement_datetime,
# measurement_time
  CAST(EXTRACT(TIME FROM DATETIME(TIMESTAMP(vfvoisci.APPROX_EVENT_DAY))) AS STRING) AS measurement_time,
# measurement_type_concept_id
  32879 AS measurement_type_concept_id,
# operator_concept_id
  vfvoisci.operator_concept_id,
# value_as_number
  SAFE_CAST(vfvoisci.measurement_value AS FLOAT64) AS value_as_number,
# value_as_concept_id
  0 AS value_as_concept_id,
# unit_concept_id
  CASE
    WHEN vfvoisci.unit_concept_id IS NOT NULL THEN vfvoisci.unit_concept_id
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
 vfvoisci.SOURCE AS measurement_source_value,
# measurement_source_concept_id
  CASE
    WHEN vfvoisci.measurement_omop_concept_id IS NOT NULL THEN CAST(vfvoisci.measurement_omop_concept_id AS INT64)
    ELSE 0
  END AS measurement_source_concept_id,
# unit_source_value
  vfvoisci.measurement_value_unit AS unit_source_value,
# unit_source_concept_id
  CASE
       WHEN vfvoisci.measurement_unit_omop_concept_id IS NOT NULL THEN vfvoisci.measurement_unit_omop_concept_id
       ELSE 0
  END AS unit_source_concept_id,
# value_source_value
  CAST(NULL AS STRING) AS value_source_value,
# measurement_event_id
  NULL AS measurement_event_id,
# meas_event_field_concept_id
  0 AS meas_event_field_concept_id
FROM variables_from_vision_omop_info_standard_concept_id AS vfvoisci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = vfvoisci.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   "SOURCE=VISION;INDEX=" = vo.visit_source_value AND
   vfvoisci.APPROX_EVENT_DAY = vo.visit_start_date
ORDER BY person_id, measurement_id;
