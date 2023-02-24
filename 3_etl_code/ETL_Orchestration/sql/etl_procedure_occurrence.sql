# DESCRIPTION:
# Creates a row in cdm-procedure occurrence table for each FinnGen id in the registries HILMO and PRIM_OUT.
# Person id is extracted from person table
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

TRUNCATE TABLE @schema_cdm_output.procedure_occurrence;
INSERT INTO @schema_cdm_output.procedure_occurrence
(
  procedure_occurrence_id,
  person_id,
  procedure_concept_id,
  procedure_date,
  procedure_datetime,
  procedure_end_date,
  procedure_end_datetime,
  procedure_type_concept_id,
  modifier_concept_id,
  quantity,
  provider_id,
  visit_occurrence_id,
  visit_detail_id,
  procedure_source_value,
  procedure_source_concept_id,
  modifier_source_value
)

WITH
# 1 - Get only Procedure events from HILMO and PRIM_OUT registries, as define form standard code or using domain
#   - Add procedure standard concept id.
procedure_from_registers_with_source_and_standard_concept_id AS (
  SELECT sme.*,
         cmap.concept_id_2
  FROM @schema_etl_input.stem_medical_events AS sme
  LEFT JOIN (
    SELECT cr.concept_id_1, cr.concept_id_2, c.domain_id
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id ='Procedure'
  ) AS cmap
  ON CAST(sme.omop_source_concept_id AS INT64) = cmap.concept_id_1
  # Here look for default domain procedure and standard domain to be either procedure or null to capture non-standard events
  WHERE sme.SOURCE IN ('INPAT','OPER_IN','OPER_OUT','OUTPAT','PRIM_OUT') AND
        sme.default_domain LIKE '%Procedure%' AND (cmap.domain_id = 'Procedure' OR cmap.domain_id IS NULL)
)

# 2 - Shape into procedure_occurrence table
SELECT
# procedure_occurrence_id
  ROW_NUMBER() OVER(ORDER by pfrwsasci.SOURCE, pfrwsasci.INDEX) AS procedure_occurrence_id,
# person_id
  p.person_id AS person_id,
# procedure_concept_id
  CASE
      WHEN pfrwsasci.concept_id_2 IS NOT NULL THEN pfrwsasci.concept_id_2
      ELSE 0
  END AS procedure_concept_id,
# procedure_date
  pfrwsasci.APPROX_EVENT_DAY AS procedure_date,
# procedure_datetime
  DATETIME(TIMESTAMP(pfrwsasci.APPROX_EVENT_DAY)) AS procedure_datetime,
# procedure_end_date
  pfrwsasci.APPROX_EVENT_DAY AS procedure_end_date,
# procedure_end_datetime
  DATETIME(TIMESTAMP(pfrwsasci.APPROX_EVENT_DAY)) AS procedure_end_datetime,
# procedure_type_concept_id
  32879 AS procedure_type_concept_id,
# modifier_concept_id
  NULL AS modifier_concept_id,
# quantity
  1 AS quantity,
# provider_id
  vo.provider_id AS provider_id,
# visit_occurrence_id
  vo.visit_occurrence_id AS visit_occurrence_id,
# visit_detail_id
  0 AS visit_detail_id,
# procedure_source_value
  pfrwsasci.CODE1 AS procedure_source_value,
# procedure_source_concept_id
CASE
  WHEN pfrwsasci.omop_source_concept_id IS NULL THEN 0
  ELSE CAST(pfrwsasci.omop_source_concept_id AS INT64)
END AS procedure_source_concept_id,
# modifier_source_value
  CAST(NULL AS STRING) AS modifier_source_value,
FROM procedure_from_registers_with_source_and_standard_concept_id AS pfrwsasci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = pfrwsasci.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   CONCAT('SOURCE=',pfrwsasci.SOURCE,';INDEX=',pfrwsasci.INDEX) = vo.visit_source_value AND
   pfrwsasci.APPROX_EVENT_DAY = vo.visit_start_date
ORDER BY person_id, procedure_occurrence_id;
