# DESCRIPTION:
# Creates a row in cdm-drug exposure table for each FinnGen id in the longitudinal data.
# Person id is extracted from person table
# Sex is extracted form fg-covariates table.
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

INSERT INTO `etl_sam_unittest_omop.drug_exposure`
(
  person_id, -- From the person table
  drug_exposure_id, -- Create each row for drug exposure id
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

SELECT ROW_NUMBER() OVER(PARTITION BY p.person_id ORDER by p.person_id,purch.APPROX_EVENT_DAY) AS drug_exposure_id,
			 p.person_id AS person_id,
			 relmap.ingredientID AS drug_concept_id,
			 purch.APPROX_EVENT_DAY AS drug_exposure_start_date,
			 FORMAT_TIMESTAMP("%F %T",timestamp(purch.APPROX_EVENT_DAY)) AS drug_exposure_start_datetime,
			 DATE_ADD(purch.APPROX_EVENT_DAY, INTERVAL 1 DAY) AS drug_exposure_end_date,
			 CAST(NULL AS DATETIME) AS drug_exposure_end_datetime,
			 CAST(NULL AS DATE) AS verbatim_end_date,
			 38000175 AS drug_type_concept_id,
			 NULL AS stop_reason,
			 NULL AS refills,
			 purch.CODE4_PLKM AS quantity,
			 NULL AS days_supply,
			 NULL AS sig,
			 NULL AS route_concept_id,
			 NULL AS lot_number,
			 NULL AS provider_id,
			 vo.visit_occurrence_id AS visit_occurrence_id,
			 NULL AS visit_detail_id,
			 purch.CODE3_VNRO AS drug_source_value,
			 fgc.omop_concept_id AS drug_source_concept_id,
			 NULL AS route_source_value,
			 NULL AS dose_unit_source_value
FROM `etl_dev_input.purch` AS purch
JOIN `etl_sam_unittest_omop.person` AS p
ON p.person_source_value = purch.FINNGENID
JOIN `medical_codes.fg_codes_info_v1` AS fgc
ON fgc.code = purch.CODE3_VNRO
JOIN `etl_sam_unittest_omop.visit_occurrence` AS vo
ON vo.person_id = p.person_id AND vo.visit_source_value = purch.SOURCE
JOIN
(

WITH drugInfo AS (
select c.concept_code, c.concept_name, r.concept_class_id,
			 c.concept_id, cr.relationship_id, cr.concept_id_2,
			 vnr.ATC, vnr.AdministrationRoute, vnr.DosageForm,
			 vnr.PackageSize,vnr.PackageFactor, vnr.PackageUnit,
			 vnr.Substance, t1.ingredientID, vnr.Strength
from `etl_sam_unittest_omop.concept` as c
JOIN `etl_sam_unittest_omop.concept_relationship` as cr
ON c.concept_id = cr.concept_id_1 AND cr.relationship_id = 'Maps to'
JOIN `medical_codes.finngen_vnr_v1` as vnr
ON CAST(vnr.VNR AS STRING) = c.concept_code
JOIN `etl_sam_unittest_omop.concept` as r
ON r.concept_id = cr.concept_id_2
JOIN
(
	WITH finalConnection AS(
		SELECT concept_id_1, relationship_id, concept_id_2
		FROM etl_sam_unittest_omop.concept_relationship
		WHERE relationship_id='Consists of'
	)
	SELECT fc.concept_id_1 AS drugID,
				 fi.concept_id_2 AS ingredientID,
				 fcr.concept_name AS ingredientName
	FROM finalConnection as fc
	JOIN etl_sam_unittest_omop.concept_relationship AS fi
	ON fc.concept_id_2=fi.concept_id_1 AND fi.relationship_id='RxNorm has ing'
	JOIN etl_sam_unittest_omop.concept AS fcr
	ON fcr.concept_id = fi.concept_id_2
	ORDER BY fc.concept_id_1
) AS t1
ON t1.drugID = cr.concept_id_2 AND t1.ingredientName = vnr.Substance
)
select *
from drugInfo


) AS relmap
ON purch.CODE3_VNRO=relmap.concept_code

