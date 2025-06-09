# DESCRIPTION:
# Creates a row in cdm.measurement table for each lab test measurment event in the cdm.kanta.
# Finds zero or more standard code for each non-standard concept_id in cdm.kanta.
# Map the columns from source kanta table to Measurement columns
# For negative values that go in cdm.measurement.value_as_number column then it needs to of the following concepts
# 3003396,3004959,3012501,3003129,3002032,3007435,3051343,21494211,21494205,21492970,21494210,21494204,21492969,
# 3052504,3049581,21494209,21494203,21492968,21494208,21494202,21494199,3021722,3051450,21494100,3051938,21494201,
# 21494198,3049418,21494200,21494197,3052486,3049278,21494099,36203243,36203246,36204416,36203244,36203245,36204415,
# 36203242,36204445,36204414,3033804,3049654,36204417,21494207,21492972,21494196,21494206,21492971,21494101,3002101,
# 3049273,21494098,3006277,3028303,3025448
# Insert resulting events into the cdm.measurement table.
# measurement_id is added by an offset of 118000000000
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
# 1 - Get all lab tests and their results from Kanta
lab_tests_kanta AS (
  SELECT *,
         "KANTA" AS SOURCE
  FROM @schema_table_kanta
  WHERE APPROX_EVENT_DATETIME IS NOT NULL
),

# 2 - append measurement_source_concept_id from fg_codes_info_v6 table with non-standard code
lab_tests_with_measurement_source_concept_id AS (
  SELECT ltk.*,
         fgc.omop_concept_id AS measurement_source_concept_id
  FROM lab_tests_kanta AS ltk
  LEFT JOIN ( SELECT code,
                     omop_concept_id
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'LABfi_ALL') AS fgc
  ON CONCAT(ltk.TEST_NAME,'[',ltk.MEASUREMENT_UNIT,']') = fgc.code
),

# 3 - append unit_source_concept_id from fg_codes_info_v6 table with non-standard code
lab_tests_with_measurement_and_unit_source_concept_id AS (
  SELECT ltwmsci.*,
         fgc.omop_concept_id AS unit_source_concept_id
  FROM lab_tests_with_measurement_source_concept_id AS ltwmsci
  LEFT JOIN ( SELECT code,
                     omop_concept_id
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'UNITfi_ALL') AS fgc
  ON ltwmsci.MEASUREMENT_UNIT = fgc.code
),

# 4 - append unit_concept_id from concept_relationship table
lab_tests_with_measurement_and_unit_source_and_standard_concept_id AS (
  SELECT ltwmusci.*,
         unitmap.concept_id_2 AS unit_concept_id
  FROM lab_tests_with_measurement_and_unit_source_concept_id AS ltwmusci
  LEFT JOIN (
    SELECT cr.concept_id_1, cr.concept_id_2, c.concept_name
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id IN ('Unit')
  ) AS unitmap
  ON
    CAST(ltwmusci.unit_source_concept_id AS INT64) = unitmap.concept_id_1
)

# 5 - Shape into measurement table
SELECT
# measurement_id
  ROW_NUMBER() OVER(ORDER by ltwmussci.FINNGENID) + 118000000000 AS measurement_id,
# person_id
  p.person_id AS person_id,
# measurement_concept_id
  CASE
      WHEN ltwmussci.OMOP_CONCEPT_ID IS NOT NULL AND ltwmussci.OMOP_CONCEPT_ID != -1 THEN ltwmussci.OMOP_CONCEPT_ID
      ELSE 0
  END AS measurement_concept_id,
# measurement_date
  EXTRACT(DATE FROM ltwmussci.APPROX_EVENT_DATETIME) AS measurement_date,
# measurement_datetime
  ltwmussci.APPROX_EVENT_DATETIME AS measurement_datetime,
# measurement_time
  CAST(EXTRACT(TIME FROM ltwmussci.APPROX_EVENT_DATETIME) AS STRING) AS measurement_time,
# measurement_type_concept_id
  32879 AS measurement_type_concept_id,
# operator_concept_id
  0 AS operator_concept_id,
# value_as_number - Negative values will only be accepted if the concept_id is from OHDSI prescribed standard concepts
  CASE
       WHEN SAFE_CAST(ltwmussci.MEASUREMENT_VALUE_HARMONIZED AS FLOAT64) < 0 AND
            ltwmussci.OMOP_CONCEPT_ID IN (3003396,3004959,3012501,3003129,3002032,3007435,3051343,21494211,21494205,21492970,21494210,21494204,21492969,
                                    3052504,3049581,21494209,21494203,21492968,21494208,21494202,21494199,3021722,3051450,21494100,3051938,21494201,
                                    21494198,3049418,21494200,21494197,3052486,3049278,21494099,36203243,36203246,36204416,36203244,36203245,36204415,
                                    36203242,36204445,36204414,3033804,3049654,36204417,21494207,21492972,21494196,21494206,21492971,21494101,3002101,
                                    3049273,21494098,3006277,3028303,3025448) THEN SAFE_CAST(ltwmussci.MEASUREMENT_VALUE_HARMONIZED AS FLOAT64)
       WHEN SAFE_CAST(ltwmussci.MEASUREMENT_VALUE_HARMONIZED AS FLOAT64) >= 0 THEN SAFE_CAST(ltwmussci.MEASUREMENT_VALUE_HARMONIZED AS FLOAT64)
       ELSE NULL
  END AS value_as_number,
# value_as_concept_id
  0 AS value_as_concept_id,
# unit_concept_id
  CASE
    WHEN ltwmussci.unit_concept_id IS NOT NULL THEN ltwmussci.unit_concept_id
    ELSE 0
  END AS unit_concept_id,
# range_low
  SAFE_CAST(REFERENCE_RANGE_LOW_VALUE AS FLOAT64) AS range_low,
# range_high
  SAFE_CAST(REFERENCE_RANGE_HIGH_VALUE AS FLOAT64) AS range_high,
# provider_id
  vo.provider_id AS provider_id,
# visit_occurrence_id
  vo.visit_occurrence_id AS visit_occurrence_id,
# visit_detail_id
  NULL AS visit_detail_id,
# measurement_source_value
 ltwmussci.TEST_NAME_SOURCE AS measurement_source_value,
# measurement_source_concept_id
  CASE
    WHEN ltwmussci.measurement_source_concept_id IS NOT NULL THEN CAST(ltwmussci.measurement_source_concept_id AS INT64)
    ELSE 0
  END AS measurement_source_concept_id,
# unit_source_value
  ltwmussci.MEASUREMENT_UNIT_SOURCE AS unit_source_value,
# unit_source_concept_id
  CASE
       WHEN ltwmussci.unit_source_concept_id IS NOT NULL THEN SAFE_CAST(ltwmussci.unit_source_concept_id AS INT64)
       ELSE 0
  END AS unit_source_concept_id,
# value_source_value
  SAFE_CAST(ltwmussci.MEASUREMENT_VALUE_SOURCE AS STRING) AS value_source_value,
# measurement_event_id
  NULL AS measurement_event_id,
# meas_event_field_concept_id
  0 AS meas_event_field_concept_id
FROM lab_tests_with_measurement_and_unit_source_and_standard_concept_id AS ltwmussci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = ltwmussci.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   "SOURCE=KANTA;INDEX=" = vo.visit_source_value AND
   EXTRACT(DATE FROM ltwmussci.APPROX_EVENT_DATETIME) = vo.visit_start_date
ORDER BY person_id, measurement_id;
