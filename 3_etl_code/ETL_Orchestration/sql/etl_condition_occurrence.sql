# DESCRIPTION:
# Creates a row in cdm.condition_occurrence table for each condition event in the cdm.stem_medical_events.
# Finds zero or more standard code for each non-standard concept_id in cdm.stem_medical_events.
# Takes only these that map to a "condition" or is no mapping these where default_domain is a "condition".
# Insert resulting events into the cdm.condition_occurrence table.
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

TRUNCATE TABLE @schema_cdm_output.condition_occurrence;
INSERT INTO @schema_cdm_output.condition_occurrence
(
    condition_occurrence_id,
    person_id,
    condition_concept_id,
    condition_start_date,
    condition_start_datetime,
    condition_end_date,
    condition_end_datetime,
    condition_type_concept_id,
    condition_status_concept_id,
    stop_reason,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    condition_source_value,
    condition_source_concept_id,
    condition_status_source_value
)

WITH
# 1 - Get only "Condition" events, as define form standard code or using default domain
# Join stem_medical_events.omop_concept_id to zero or more "Condition" standard codes in vocab.concept_relationship table
# Take these with "Condition" standard mappings or with default_mapping contains "Condition"
condition_from_registers_with_source_and_standard_concept_id AS (
  SELECT sme.*,
         cmap.concept_id_2
  FROM @schema_etl_input.stem_medical_events AS sme
  LEFT JOIN (
    SELECT cr.concept_id_1, cr.concept_id_2, c.domain_id
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id ='Condition'
  ) AS cmap
  ON CAST(sme.omop_source_concept_id AS INT64) = cmap.concept_id_1
  # Here look for default domain condition and standard domain to be either condition or null to capture non-standard events
  WHERE sme.default_domain LIKE '%Condition%' AND (cmap.domain_id = 'Condition' OR cmap.domain_id IS NULL)
)

# 2 - Shape into condition_occurrence table
SELECT
# condition_occurrence_id
  ROW_NUMBER() OVER(ORDER by cfrwsasci.SOURCE, cfrwsasci.INDEX) AS condition_occurrence_id,
# person_id
  p.person_id AS person_id,
# condition_concept_id
  CASE
      WHEN cfrwsasci.concept_id_2 IS NOT NULL THEN cfrwsasci.concept_id_2
      ELSE 0
  END AS condition_concept_id,
# condition_start_date
  cfrwsasci.APPROX_EVENT_DAY AS condition_start_date,
# condition_start_datetime
  DATETIME(TIMESTAMP(cfrwsasci.APPROX_EVENT_DAY)) AS condition_start_datetime,
# condition_end_date
  CASE
      WHEN cfrwsasci.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') AND cfrwsasci.CODE4 IS NOT NULL AND CAST(cfrwsasci.CODE4 AS INT64) > 1 THEN DATE_ADD(cfrwsasci.APPROX_EVENT_DAY, INTERVAL CAST(cfrwsasci.CODE4 AS INT64) DAY)
      ELSE cfrwsasci.APPROX_EVENT_DAY
  END AS condition_end_date,
# condition_end_datetime
  CASE
      WHEN cfrwsasci.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') AND cfrwsasci.CODE4 IS NOT NULL AND CAST(cfrwsasci.CODE4 AS INT64) > 1 THEN DATETIME(TIMESTAMP(DATE_ADD(cfrwsasci.APPROX_EVENT_DAY, INTERVAL CAST(cfrwsasci.CODE4 AS INT64) DAY)))
      ELSE DATETIME(TIMESTAMP(cfrwsasci.APPROX_EVENT_DAY))
  END AS condition_end_datetime,
# condition_type_concept_id
  32879 AS condition_type_concept_id,
# condition_status_concept_id
  CASE
      WHEN cfrwsasci.SOURCE IN ('INPAT','OUTPAT') AND cfrwsasci.CATEGORY = '0' THEN 32902
      WHEN cfrwsasci.SOURCE IN ('INPAT','OUTPAT') AND REGEXP_CONTAINS(cfrwsasci.CATEGORY,r'^[1-9]\d*$') THEN 32908
      WHEN cfrwsasci.SOURCE IN ('INPAT','OUTPAT') AND REGEXP_CONTAINS(cfrwsasci.CATEGORY,r'^(EX|EX\d*)$') THEN 32895
      WHEN cfrwsasci.SOURCE IN ('PRIM_OUT') AND cfrwsasci.CATEGORY IN ('ICD0','ICP0') THEN 32902
      WHEN cfrwsasci.SOURCE IN ('PRIM_OUT') AND REGEXP_CONTAINS(cfrwsasci.CATEGORY,r'^(ICD|ICP)[1-9]\d*$') THEN 32908
      WHEN cfrwsasci.SOURCE = 'REIMB' THEN 32893
      WHEN cfrwsasci.SOURCE = 'DEATH' AND cfrwsasci.CATEGORY = 'U' THEN 32911
      WHEN cfrwsasci.SOURCE = 'DEATH' AND cfrwsasci.CATEGORY = 'I' THEN 32897
      WHEN cfrwsasci.SOURCE = 'DEATH' AND LOWER(cfrwsasci.CATEGORY) IN ('c1','c2','c3','c4') THEN 32894
      WHEN cfrwsasci.SOURCE = 'CANC' THEN 32902
      ELSE NULL
  END AS condition_status_concept_id,
# stop_reason
  CAST(NULL AS STRING) AS stop_reason,
# provider_id
  vo.provider_id AS provider_id,
# visit_occurrence_id
  vo.visit_occurrence_id AS visit_occurrence_id,
# visit_detail_id
  0 AS visit_detail_id,
# condition_source_value
  CONCAT(
    'CODE1=',  (CASE WHEN cfrwsasci.CODE1 IS NULL THEN "" ELSE cfrwsasci.CODE1 END),
    ';CODE2=', (CASE WHEN cfrwsasci.CODE2 IS NULL THEN "" ELSE cfrwsasci.CODE2 END),
    ';CODE3=', (CASE WHEN cfrwsasci.CODE3 IS NULL THEN "" ELSE cfrwsasci.CODE3 END)
  ) AS condition_source_value,
# condition_source_concept_id
CASE
  WHEN cfrwsasci.omop_source_concept_id IS NULL THEN 0
  ELSE CAST(cfrwsasci.omop_source_concept_id AS INT64)
END AS condition_source_concept_id,
# condition_status_source_value
  cfrwsasci.CATEGORY AS condition_status_source_value,
FROM condition_from_registers_with_source_and_standard_concept_id AS cfrwsasci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = cfrwsasci.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   CONCAT('SOURCE=',cfrwsasci.SOURCE,';INDEX=',cfrwsasci.INDEX) = vo.visit_source_value AND
   cfrwsasci.APPROX_EVENT_DAY = vo.visit_start_date
ORDER BY person_id, condition_occurrence_id;
