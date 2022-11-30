# DESCRIPTION:
# Creates a row in cdm-drug exposure table for each FinnGen id in the longitudinal data.
# Person id is extracted from person table
# Sex is extracted form fg-covariates table.
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

INSERT INTO @schema_cdm_output.drug_expsoure
(
  person_id, -- From the person table
  drug_exposure_id, -- Create each row for drug exposure id
	person_id,
	drug_concept_id,
	drug_exposure_start_date, -- EXTRACT( YEAR FROM birth_datetime)
	drug_exposure_start_datetime, -- ( YEAR FROM birth_datetime)
	drug_exposure_end_date,
	drug_exposure_end_datetime,
	verbatim_end_date,
	drug_type_concept_id,
	stop_reason,
	refills,
	quantity,
	days_supply,
	sig,
	route_concept_id,
	lot_number,
	provider_id,
	visit_occurrence_id,
	visit_detail_id,
	drug_source_value,
	drug_source_concept_id,
	route_source_value,
	dose_unit_source_value
)

SELECT
row_number()over(order by dot.person_id,dot.visit_start_DATE) AS drug_exposure_id,
dot.person_id AS person_id,
relmap.drug_concept_id AS drug_concept_id,
dot.visit_start_DATE AS drug_exposure_start_DATE,
dot.visit_start_DATETIME AS drug_exposure_start_DATETIME,
dot.visit_start_DATE AS drug_exposure_end_DATE,
dot.visit_start_DATETIME AS drug_exposure_end_DATETIME,
dot.visit_start_DATE AS verbatim_end_DATE,
38000175 AS drug_type_concept_id,
NULL AS stop_reason,
NULL AS refills,
dot.CODE4 AS quantity,
NULL AS days_supply,
NULL AS sig,
NULL AS route_concept_id,
NULL AS lot_number,
NULL AS provider_id,
dot.visit_occurence_id AS visit_occurrence_id,
NULL AS visit_detail_id,
dot.CODE3 AS drug_source_value,
relmap.source_value_concept_id AS drug_source_concept_id,
NULL AS route_source_value,
NULL AS dose_unit_source_value
FROM doTemp AS dot
JOIN
(
WITH finalConnection AS(
WITH maps AS (
SELECT c.concept_code,
c.concept_id,
cr.concept_id_2
FROM cdm_vocabulary.concept AS c
JOIN cdm_vocabulary.concept_relationship AS cr
ON c.concept_id=cr.concept_id_1
WHERE c.vocabulary_id='VNR'
    AND c.concept_code != ''
    AND c.concept_class_id='Clinical Drug'
    #AND c.concept_code='001004'
)
SELECT m.concept_code,
m.concept_id,
i.concept_id_2
FROM maps AS m
JOIN cdm_vocabulary.concept_relationship AS i
ON m.concept_id_2=i.concept_id_1 AND i.relationship_id='Consists of'
)
SELECT fc.concept_code AS source_value,
fc.concept_id AS source_value_concept_id,
fi.concept_id_2 AS drug_concept_id
FROM finalConnection as fc
JOIN cdm_vocabulary.concept_relationship AS fi
ON fc.concept_id_2=fi.concept_id_1 AND fi.relationship_id='RxNorm has ing'
ORDER BY fc.concept_code
) AS relmap
ON dot.CODE3=relmap.source_value
