# DESCRIPTION:
# Creates a row in cdm.measurement table for each hla imputed code in the source.hla_imputed.
# Currently no mapping is done. Only the source codes are used.
# Insert resulting events into the cdm.measurement table.
# measurement_id is added by an offset of 119000000000
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

WITH hla_imputed AS (
  SELECT FINNGENID, Allele, HLAcode
  FROM @schema_hla_imputed
),
hla_imputed_source_code AS (
  SELECT hi.FINNGENID,
         hi.Allele,
         hi.HLAcode,
         c.concept_id AS omop_concept_id, 
         CASE
              WHEN fi.BL_YEAR > EXTRACT(YEAR FROM CURRENT_DATE()) THEN '2024-12-18' # THIS IS ONLY FOR atlas-development
              ELSE DATE_ADD(DATE(fi.BL_YEAR, 1, 1), INTERVAL CAST((fi.BL_AGE - FLOOR(fi.BL_AGE)) * 365 AS INT64) DAY) 
         END AS APPROX_EVENT_DAY
  FROM hla_imputed AS hi
  LEFT JOIN @schema_vocab.concept AS c
  ON c.concept_code = hi.HLAcode
  LEFT JOIN @schema_table_finngenid AS fi
  ON fi.FINNGENID = hi.FINNGENID
)
# 5 - Shape into measurement table
SELECT
# measurement_id
  ROW_NUMBER() OVER(ORDER by hisc.FINNGENID) + 119000000000 AS measurement_id,
# person_id
  p.person_id AS person_id,
# measurement_concept_id
  0 AS measurement_concept_id,
# measurement_date
  APPROX_EVENT_DAY AS measurement_date,
# measurement_datetime
  DATETIME(TIMESTAMP(APPROX_EVENT_DAY)) AS measurement_datetime,
# measurement_time
  CAST(EXTRACT(TIME FROM DATETIME(TIMESTAMP(APPROX_EVENT_DAY))) AS STRING) AS measurement_time,
# measurement_type_concept_id
  32879 AS measurement_type_concept_id,
# operator_concept_id
  0 AS operator_concept_id,
# value_as_number - Negative values will only be accepted if the concept_id is from OHDSI prescribed standard concepts
  NULL AS value_as_number,
# value_as_concept_id
  0 AS value_as_concept_id,
# unit_concept_id
  0 AS unit_concept_id,
# range_low
  NULL AS range_low,
# range_high
  NULL AS range_high,
# provider_id
  NULL AS provider_id,
# visit_occurrence_id
  NULL AS visit_occurrence_id,
# visit_detail_id
  NULL AS visit_detail_id,
# measurement_source_value
   CONCAT(hisc.HLAcode,' with allele ',hisc.Allele) AS measurement_source_value,
# measurement_source_concept_id
  hisc.omop_concept_id AS measurement_source_concept_id,
# unit_source_value
  CAST(NULL AS STRING) AS unit_source_value,
# unit_source_concept_id
  0 AS unit_source_concept_id,
# value_source_value
  CAST(NULL AS STRING) AS value_source_value,
# measurement_event_id
  NULL AS measurement_event_id,
# meas_event_field_concept_id
  0 AS meas_event_field_concept_id
FROM hla_imputed_source_code AS hisc
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = hisc.FINNGENID
ORDER BY person_id, measurement_id;
