# DESCRIPTION:
# Creates a row in cdm-visit occurence table for each event of FinnGen id in the longitudinal data.
# Person id is extracted from person table
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

INSERT INTO @schema_cdm_output.visit_occurence
(
  visit_occurrence_id,
  person_id,
  visit_concept_id,
  visit_start_date,
  visit_start_datetime,
  visit_end_date,
  visit_end_datetime,
	visit_type_concept_id,
	provider_id,
	care_site_id,
	visit_source_value,
	visit_source_concept_id,
	admitted_from_concept_id,
	admitted_from_source_value,
	discharged_to_concept_id,
	discharged_to_source_value,
	preceding_visit_occurrence_id
)

SELECT row_number()over(order by vot.person_id,vot.APPROX_EVENT_DAY) AS visit_occurence_id,
       vot.person_id AS person_id,
       m.concept_id_1 AS visit_concept_id,
       vot.APPROX_EVENT_DAY AS visit_start_DATE,
       FORMAT_TIMESTAMP("%F %T",timestamp(vot.APPROX_EVENT_DAY)) AS visit_start_DATETIME,
       DATE_ADD(vot.APPROX_EVENT_DAY, INTERVAL 1 DAY) AS visit_end_DAE,
       FORMAT_TIMESTAMP("%F %T",timestamp(DATE_ADD(vot.APPROX_EVENT_DAY, INTERVAL 1 DAY))) AS visit_end_DATETIME,
       m.concept_id_2 AS visit_type_concept_id,
       NULL AS provider_id,
       NULL AS care_site_id,
       vot.SOURCE AS vist_source_value,
       NULL AS visit_source_concept_id,
       NULL AS admitting_source_concept_id,
       NULL AS admitting_source_value,
       NULL AS discharge_to_concept_id,
       NULL AS discharge_to_source_value,
       NULL AS preceding_visit_occurrence_id
FROM voTemp AS vot
JOIN(
      SELECT c.concept_code,
             cr.concept_id_1,
             cr.concept_id_2
      FROM cdm_vocabulary.concept AS c
      JOIN cdm_vocabulary.concept_relationship as cr
      ON c.concept_id=cr.concept_id_1
      WHERE c.vocabulary_id='FG SOURCE'
) AS m
ON m.concept_code LIKE '%' || vot.SOURCE || '%';
