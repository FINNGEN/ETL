# DESCRIPTION:
# Creates a row in cdm.device_exposure table for each device event in the cdm.stem_medical_events.
# Finds zero or more standard code for each non-standard concept_id in cdm.stem_medical_events.
# Takes only these that map to a "device" [or is no mapping these where default_domain is a "device" NO SUCH CASES ATM].
# Insert resulting events into the cdm.device_exposure table.
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

TRUNCATE TABLE @schema_cdm_output.device_exposure;
INSERT INTO @schema_cdm_output.device_exposure
(
  device_exposure_id,
  person_id,
  device_concept_id,
  device_exposure_start_date,
  device_exposure_start_datetime,
  device_exposure_end_date,
  device_exposure_end_datetime,
  device_type_concept_id,
  unique_device_id,
  production_id,
  quantity,
  provider_id,
  visit_occurrence_id,
  visit_detail_id,
  device_source_value,
  device_source_concept_id,
  unit_concept_id,
  unit_source_value,
  unit_source_concept_id
)

WITH
# 1 - Get only "Device" events, as define form standard code or using default domain
# Join stem_medical_events.omop_concept_id to zero or more "Device" standard codes in vocab.concept_relationship table
# Take these with "Device" standard mappings or with default_mapping contains "Device"
device_exposure_from_registers_with_source_and_standard_concept_id AS (
  SELECT sme.*,
         cmap.concept_id_2
  FROM @schema_etl_input.stem_medical_events AS sme
  LEFT JOIN (
    SELECT cr.concept_id_1, cr.concept_id_2, c.domain_id
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id ='Device'
  ) AS cmap
  ON CAST(sme.omop_source_concept_id AS INT64) = cmap.concept_id_1
  # Here look for default domain device and standard domain to be device
  WHERE sme.default_domain LIKE '%Device%' AND (cmap.domain_id = 'Device' OR cmap.domain_id IS NULL)
)

# 2 - Shape into device exposure table
SELECT
# device_exposure_id
  ROW_NUMBER() OVER(ORDER by defrwsasci.SOURCE, defrwsasci.INDEX) AS device_exposure_id,
# person_id
  p.person_id AS person_id,
# device_concept_id
  CASE
      WHEN defrwsasci.concept_id_2 IS NOT NULL THEN defrwsasci.concept_id_2
      ELSE 0
  END AS device_concept_id,
# device_exposure_start_date
  defrwsasci.APPROX_EVENT_DAY AS device_exposure_start_date,
# device_exposure_start_datetime
  DATETIME(TIMESTAMP(defrwsasci.APPROX_EVENT_DAY)) AS device_exposure_start_datetime,
# device_exposure_end_date
  defrwsasci.APPROX_EVENT_DAY AS device_exposure_end_date,
# device_exposure_end_datetime
  DATETIME(TIMESTAMP(defrwsasci.APPROX_EVENT_DAY)) AS device_exposure_end_datetime,
# device_type_concept_id
  32879 AS device_type_concept_id,
# unique_device_id
  CAST(NULL AS STRING) AS unique_device_id,
# production_id
  CAST(NULL AS STRING) AS production_id,
# quantity
  NULL AS quantity,
# provider_id
  vo.provider_id AS provider_id,
# visit_occurrence_id
  vo.visit_occurrence_id AS visit_occurrence_id,
# visit_detail_id
  0 AS visit_detail_id,
# device_source_value
  defrwsasci.CODE1 AS device_source_value,
# device_source_concept_id
CASE
  WHEN defrwsasci.omop_source_concept_id IS NULL THEN 0
  ELSE CAST(defrwsasci.omop_source_concept_id AS INT64)
END AS device_source_concept_id,
# unit_concept_id
  NULL AS unit_concept_id,
# unit_source_value
  CAST(NULL AS STRING) AS unit_source_value,
# unit_source_concept_id
  NULL AS unit_source_concept_id
FROM device_exposure_from_registers_with_source_and_standard_concept_id AS defrwsasci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = defrwsasci.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   CONCAT('SOURCE=',defrwsasci.SOURCE,';INDEX=',defrwsasci.INDEX) = vo.visit_source_value AND
   defrwsasci.APPROX_EVENT_DAY = vo.visit_start_date
ORDER BY person_id, device_exposure_id;
