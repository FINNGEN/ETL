# DESCRIPTION:
# Creates a row in cdm.observation table for each observation event in the cdm.stem_medical_events.
# Finds zero or more standard code for each non-standard concept_id in cdm.stem_medical_events.
# Takes only these that map to a "observation" [or is no mapping these where default_domain is a "observation" NO SUCH CASES ATM].
# Insert resulting events into the cdm.observation table.
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

TRUNCATE TABLE @schema_cdm_output.observation;
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
# 1 - Get only "Observation" events, as define form standard code or using default domain
# Join stem_medical_events.omop_concept_id to zero or more "Observation" standard codes in vocab.concept_relationship table
# Take these with "Observation" standard mappings or with default_mapping contains "Observation"
observation_from_registers_with_source_and_standard_concept_id AS (
  SELECT sme.*,
         cmap.concept_id_2
  FROM @schema_etl_input.stem_medical_events AS sme
  LEFT JOIN (
    SELECT cr.concept_id_1, cr.concept_id_2, c.domain_id
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id ='Observation'
  ) AS cmap
  ON CAST(sme.omop_source_concept_id AS INT64) = cmap.concept_id_1
  # Here look for default domain observation and standard domain to be observation
  #WHERE sme.default_domain LIKE '%Obs%' AND (cmap.domain_id = 'Observation' OR cmap.domain_id IS NULL)
  WHERE cmap.domain_id = 'Observation'  OR  (cmap.domain_id IS NULL AND sme.default_domain LIKE '%Obs%')
)

# 2 - Shape into observation table
SELECT
# observation_id
  ROW_NUMBER() OVER(ORDER by ofrwsasci.SOURCE, ofrwsasci.INDEX) AS observation_id,
# person_id
  p.person_id AS person_id,
# observation_concept_id
  CASE
      WHEN ofrwsasci.concept_id_2 IS NOT NULL THEN ofrwsasci.concept_id_2
      ELSE 0
  END AS observation_concept_id,
# observation_date
  ofrwsasci.APPROX_EVENT_DAY AS observation_date,
# observation_datetime
  DATETIME(TIMESTAMP(ofrwsasci.APPROX_EVENT_DAY)) AS observation_datetime,
# observation_type_concept_id
  32879 AS observation_type_concept_id,
# value_as_number
  NULL AS value_as_number,
# value_as_string
  CAST(NULL AS STRING) AS value_as_string,
# value_as_concept_id
  NULL AS value_as_concept_id,
# qualifier_concept_id
  NULL AS qualifier_concept_id,
# unit_concept_id
  NULL AS unit_concept_id,
# provider_id
  vo.provider_id AS provider_id,
# visit_occurrence_id
  vo.visit_occurrence_id AS visit_occurrence_id,
# visit_detail_id
  NULL AS visit_detail_id,
# observation_source_value
  ofrwsasci.CODE1 AS observation_source_value,
# observation_source_concept_id
#  CASE
#    WHEN ofrwsasci.omop_source_concept_id IS NULL THEN 0
#    ELSE CAST(ofrwsasci.omop_source_concept_id AS INT64)
#  END AS observation_source_concept_id,
  CAST(ofrwsasci.omop_source_concept_id AS INT64) AS observation_source_concept_id,
# unit_source_value
  CAST(NULL AS STRING) AS unit_source_value,
# qualifier_source_value
  CAST(NULL AS STRING) AS qualifier_source_value,
# value_source_value
  CAST(NULL AS STRING) AS value_source_value,
# observation_event_id
  NULL AS observation_event_id,
# obs_event_field_concept_id
  NULL AS obs_event_field_concept_id
FROM observation_from_registers_with_source_and_standard_concept_id AS ofrwsasci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = ofrwsasci.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   CONCAT('SOURCE=',ofrwsasci.SOURCE,';INDEX=',ofrwsasci.INDEX) = vo.visit_source_value AND
   ofrwsasci.APPROX_EVENT_DAY = vo.visit_start_date
ORDER BY person_id, observation_id;
