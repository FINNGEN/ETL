# DESCRIPTION:
# Creates a row in cdm-visit occurrence table for each event of FinnGen id in the longitudinal data.
# Person id is extracted from person table
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

INSERT INTO @schema_cdm_output.visit_occurrence
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

SELECT ROW_NUMBER() OVER(PARTITION BY p.person_id ORDER BY p.person_id,ssdl.APPROX_EVENT_DAY) AS visit_occurrence_id,
       p.person_id AS person_id,
       CASE
            WHEN 'INPAT/OPER_IN' LIKE '%' || ssdl.SOURCE || '%' THEN 2000000003
            WHEN 'OUTPAT/OPER_OUT' LIKE '%' || ssdl.SOURCE || '%' THEN 2000000004
            WHEN ssdl.SOURCE = 'REIMB' THEN 2000000005
            WHEN ssdl.SOURCE = 'CANC' THEN 2000000006
            WHEN ssdl.SOURCE = 'PURCH' THEN 2000000007
            WHEN ssdl.SOURCE = 'PRIM_OUT' THEN 2000000008
            ELSE 0
       END AS visit_concept_id,
       ssdl.APPROX_EVENT_DAY AS visit_start_date,
       DATETIME(TIMESTAMP(ssdl.APPROX_EVENT_DAY)) AS visit_start_datetime,
       DATE_ADD(ssdl.APPROX_EVENT_DAY, INTERVAL 1 DAY) AS visit_end_date,
       DATETIME(TIMESTAMP(DATE_ADD(ssdl.APPROX_EVENT_DAY, INTERVAL 1 DAY))) AS visit_end_datetime,
       32879 AS visit_type_concept_id,
       0 AS provider_id,
       0 AS care_site_id,
       ssdl.SOURCE AS vist_source_value,
       0 AS visit_source_concept_id,
       0 AS admitted_from_concept_id,
       '' AS admitted_from_source_value,
       0 AS discharged_to_concept_id,
       '' AS discharged_to_source_value,
       0 AS preceding_visit_occurrence_id
FROM @schema_table_service_sector AS ssdl
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = ssdl.FINNGENID
ORDER BY person_id, visit_occurrence_id;
