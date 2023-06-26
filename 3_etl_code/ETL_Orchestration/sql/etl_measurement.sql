# DESCRIPTION:
# Creates a row in cdm.measurement table for each measurement event in the cdm.stem_medical_events.
# Finds zero or more standard code for each non-standard concept_id in cdm.stem_medical_events.
# Takes only these that map to a "measurement" [or is no mapping these where default_domain is a "measurement" NO SUCH CASES ATM].
# Insert resulting events into the cdm.measurement table.
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

TRUNCATE TABLE @schema_cdm_output.measurement;
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
# 1 - Get only "Measurement" events, as define form standard code or using default domain
# Join stem_medical_events.omop_concept_id to zero or more "Measurement" standard codes in vocab.concept_relationship table
# Take these with "Measurement" standard mappings or with default_mapping contains "Measurement"
measurement_from_registers_with_source_and_standard_concept_id AS (
  SELECT sme.*,
         cmap.concept_id_2
  FROM @schema_etl_input.stem_medical_events AS sme
  LEFT JOIN (
    SELECT cr.concept_id_1, cr.concept_id_2, c.domain_id
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id ='Measurement'
  ) AS cmap
  ON CAST(sme.omop_source_concept_id AS INT64) = cmap.concept_id_1
  # Here look for default domain measurement and standard domain to be measurement
  #WHERE sme.default_domain LIKE '%Meas%' AND (cmap.domain_id = 'Measurement' OR cmap.domain_id IS NULL)
  #WHERE cmap.domain_id = 'Measurement'  OR  (cmap.domain_id IS NULL AND sme.default_domain = 'Meas/Procedure')
  WHERE (cmap.domain_id = 'Measurement' AND sme.default_domain != 'Procedure')  OR
        (cmap.domain_id IS NULL AND sme.default_domain IN ('Measurement','Meas/Procedure'))
)

# 2 - Shape into measurement table
SELECT
# measurement_id
  ROW_NUMBER() OVER(ORDER by mfrwsasci.SOURCE, mfrwsasci.INDEX) AS measurement_id,
# person_id
  p.person_id AS person_id,
# measurement_concept_id
  CASE
      WHEN mfrwsasci.concept_id_2 IS NOT NULL THEN mfrwsasci.concept_id_2
      ELSE 0
  END AS measurement_concept_id,
# measurement_date
  mfrwsasci.APPROX_EVENT_DAY AS measurement_date,
# measurement_datetime
  DATETIME(TIMESTAMP(mfrwsasci.APPROX_EVENT_DAY)) AS measurement_datetime,
# measurement_time
  CAST(EXTRACT(TIME FROM DATETIME(TIMESTAMP(mfrwsasci.APPROX_EVENT_DAY))) AS STRING) AS measurement_time,
# measurement_type_concept_id
  32879 AS measurement_type_concept_id,
# operator_concept_id
  0 AS operator_concept_id,
# value_as_number
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
  vo.provider_id AS provider_id,
# visit_occurrence_id
  vo.visit_occurrence_id AS visit_occurrence_id,
# visit_detail_id
  NULL AS visit_detail_id,
# measurement_source_value
  mfrwsasci.CODE1 AS measurement_source_value,
# measurement_source_concept_id
  CASE
    WHEN mfrwsasci.omop_source_concept_id IS NOT NULL THEN CAST(mfrwsasci.omop_source_concept_id AS INT64)
    ELSE 0
  END AS measurement_source_concept_id,
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
FROM measurement_from_registers_with_source_and_standard_concept_id AS mfrwsasci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = mfrwsasci.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   CONCAT('SOURCE=',mfrwsasci.SOURCE,';INDEX=',mfrwsasci.INDEX) = vo.visit_source_value AND
   mfrwsasci.APPROX_EVENT_DAY = vo.visit_start_date
ORDER BY person_id, measurement_id;
