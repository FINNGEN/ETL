/* DESCRIPTION:
Creates a row in cdm-drug exposure table for each FinnGen id in the PURCH registry.
Person id is extracted from person table

PARAMETERS:
- schema_etl_input: schema with the etl input tables
- schema_cdm_output: schema with the output CDM tables
- schema_table_codes_info: support table used during the ETL
- schema_vocab: schema with the OMOP vocabularies
*/


truncate table @schema_cdm_output.drug_exposure;
insert into @schema_cdm_output.drug_exposure
(
  	drug_exposure_id,
	person_id,
	drug_concept_id,
	drug_exposure_start_date,
	drug_exposure_start_datetime,
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

-- step 1: get all purchase events from the purch registry
with purchases_from_registers as (
	select
		finngenid,
		source,
		approx_event_day,
		code1_atc_code as code1,
		code3_vnro as code3,
		code4_plkm as code4,
		index
	from
		@schema_etl_input.purch
),
-- step 2: add vnr omop concept id
purchases_from_registers_vnr_info as (
	select
		pg.finngenid,
		pg.source,
		pg.approx_event_day,
		pg.code1,
		pg.code3,
		pg.code4,
		pg.index,
		fgc.omop_concept_id as drug_omop_concept_id,
		fgc.name_en as medicine_name
	from
		purchases_from_registers as pg
	left join (
		select
			fg_code1,
			omop_concept_id,
			name_en
		from
			@schema_table_codes_info
		where
			vocabulary_id = 'VNRfi'
	  ) as fgc on
		fgc.fg_code1 = lpad(pg.code3, 6, '0')
),
-- step 3: add standard concept id
purchases_from_registers_vnr_info_standard_concept_id as (
select
	prvi.finngenid,
	prvi.source,
	prvi.approx_event_day,
	prvi.code1,
	prvi.code3,
	prvi.code4,
	prvi.index,
	prvi.drug_omop_concept_id,
	prvi.medicine_name,
	drugmap.concept_id_2
from
	purchases_from_registers_vnr_info as prvi
left join (
	select
		cr.concept_id_1,
		cr.concept_id_2,
		c.concept_class_id,
		c.concept_name
	from
		@schema_vocab.concept_relationship as cr
	join @schema_vocab.concept as c on
		cr.concept_id_2 = c.concept_id
	where
		cr.relationship_id = 'Maps to'
		and c.domain_id in ('Drug')
  ) as drugmap on
	cast(prvi.drug_omop_concept_id as int) = drugmap.concept_id_1
)

select
	row_number() over(order by prvisci.source, prvisci.index) as drug_exposure_id,
	p.person_id as person_id,
	coalesce(prvisci.concept_id_2, 0) as drug_concept_id,
	prvisci.approx_event_day as drug_exposure_start_date,
	cast(prvisci.approx_event_day as datetime) as drug_exposure_start_datetime,
	prvisci.approx_event_day as drug_exposure_end_date,
	cast(prvisci.approx_event_day as datetime) as drug_exposure_end_datetime,
	null as verbatim_end_date,
	32879 as drug_type_concept_id,
	null as stop_reason, 
	null as refills,
	coalesce(cast(prvisci.code4 as float), 0) as quantity,
	1 as days_supply,
	prvisci.medicine_name as sig,
	0 as route_concept_id,
	null as lot_number,
	vo.provider_id as provider_id,
	vo.visit_occurrence_id as visit_occurrence_id,
	null as visit_detail_id,
	-- TODO regular expressions and SqlRender. This probably works only because it's already in postgresql format. 
	-- Regular experssions seem not to translate with SqlRender. 
	case 
		/* If numeric, pad with zeros from the left until length is 6 digits.
		 * ^ means "start of the string"
		 * [0-9] character class that matches any digit from 0 to 9
		 * + means "one or more of the preceding element" (in this case "one or more digits")
		 * $ means "end of the string"
		 */
		when prvisci.code3~'^[0-9]+$' then lpad(prvisci.code3, 6, '0')
		else prvisci.code3
	end as drug_source_value, 
	coalesce(cast(prvisci.drug_omop_concept_id as int), 0) as drug_source_concept_id,
	null as route_source_value,
	null as dose_unit_source_value
from
	purchases_from_registers_vnr_info_standard_concept_id as prvisci
join @schema_cdm_output.person as p on
	p.person_source_value = prvisci.finngenid
left join @schema_cdm_output.visit_occurrence as vo on
	vo.person_id = p.person_id
	and concat('SOURCE=',prvisci.source,';INDEX=',prvisci.index) = vo.visit_source_value
	and prvisci.approx_event_day = vo.visit_start_date
-- original implementation had ordering or rows, propably not necessary here
-- order by
-- 	p.person_id,
-- 	prvisci.approx_event_day
;


/*
# DESCRIPTION:
# Creates a row in cdm-drug exposure table for each FinnGen id in the PURCH registry.
# Person id is extracted from person table
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables


TRUNCATE TABLE @schema_cdm_output.drug_exposure;
INSERT INTO @schema_cdm_output.drug_exposure
(
  drug_exposure_id,
  person_id,
  drug_concept_id,
  drug_exposure_start_date,
  drug_exposure_start_datetime,
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

WITH
# 1 - Get all purchase events form the PURCH registry
purchases_from_registers AS (
  SELECT *
  FROM(
    SELECT FINNGENID,
           SOURCE,
           APPROX_EVENT_DAY,
           CODE1_ATC_CODE AS CODE1,
           CODE3_VNRO AS CODE3,
           CODE4_PLKM AS CODE4,
           INDEX
    FROM @schema_etl_input.purch
  )
),
# 2 - Add vnr omop concept id
purchases_from_registers_vnr_info AS (
  SELECT pg.FINNGENID,
         pg.SOURCE,
         pg.APPROX_EVENT_DAY,
         pg.CODE1,
         pg.CODE3,
         pg.CODE4,
         pg.INDEX,
         fgc.omop_concept_id AS drug_omop_concept_id,
         fgc.name_en AS medicine_name
  FROM purchases_from_registers AS pg
  LEFT JOIN ( SELECT FG_CODE1,
                     omop_concept_id,
                     name_en
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'VNRfi') AS fgc
  ON fgc.FG_CODE1 = LPAD(pg.CODE3,6,'0')
),
# 3 - Add standard concept id
purchases_from_registers_vnr_info_standard_concept_id AS (
  SELECT prvi.FINNGENID,
         prvi.SOURCE,
         prvi.APPROX_EVENT_DAY,
         prvi.CODE1,
         prvi.CODE3,
         prvi.CODE4,
         prvi.INDEX,
         prvi.drug_omop_concept_id,
         prvi.medicine_name,
         drugmap.concept_id_2
  FROM purchases_from_registers_vnr_info AS prvi
  LEFT JOIN (
    SELECT cr.concept_id_1,
           cr.concept_id_2,
           c.concept_class_id,
           c.concept_name
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id IN ('Drug')
  ) AS drugmap
  ON CAST(prvi.drug_omop_concept_id AS INT64) = drugmap.concept_id_1
)

# 4 - Shape into drug exposure table
SELECT
# drug_exposure_id
  ROW_NUMBER() OVER(ORDER by prvisci.SOURCE, prvisci.INDEX) AS drug_exposure_id,
# person_id
  p.person_id AS person_id,
# drug_concept_id
 CASE
     WHEN prvisci.concept_id_2 IS NOT NULL THEN prvisci.concept_id_2
		  ELSE 0
 END AS drug_concept_id,
# drug_exposure_start_date
  prvisci.APPROX_EVENT_DAY AS drug_exposure_start_date,
# drug_exposure_start_datetime
  DATETIME(TIMESTAMP(prvisci.APPROX_EVENT_DAY)) AS drug_exposure_start_datetime,
# drug_exposure_end_date
  prvisci.APPROX_EVENT_DAY AS drug_exposure_end_date,
# drug_exposure_end_datetime
  DATETIME(TIMESTAMP(prvisci.APPROX_EVENT_DAY)) AS drug_exposure_end_datetime,
# verbatim_end_date
  CAST(NULL AS DATE) AS verbatim_end_date,
# drug_type_concept_id
  32879 AS drug_type_concept_id,
# stop_reason
  CAST(NULL AS STRING) AS stop_reason,
# refills
  NULL AS refills,
# quantity
  CASE
      WHEN prvisci.CODE4 IS NOT NULL THEN CAST(prvisci.CODE4 AS FLOAT64)
      ELSE 0
  END AS quantity,
# days_supply
  1 AS days_supply,
# sig
  prvisci.medicine_name AS sig,
# route_concept_id
  0 AS route_concept_id,
# lot_number
  CAST(NULL AS STRING) AS lot_number,
# provider_id
  vo.provider_id AS provider_id,
# visit_occurrence_id
  vo.visit_occurrence_id AS visit_occurrence_id,
# visit_detail_id
  NULL AS visit_detail_id,
# drug_source_value
  CASE
      WHEN SAFE_CAST(prvisci.CODE3 AS INT64) > 0 THEN LPAD(prvisci.CODE3,6,'0')
      ELSE prvisci.CODE3
  END AS drug_source_value,
# drug_source_concept_id
 CASE
     WHEN prvisci.drug_omop_concept_id IS NOT NULL THEN CAST(prvisci.drug_omop_concept_id AS INT64)
     ELSE 0
 END AS drug_source_concept_id,
# route_source_value
  CAST(NULL AS STRING) AS route_source_value,
# dose_unit_source_value
  CAST(NULL AS STRING) AS dose_unit_source_value
FROM purchases_from_registers_vnr_info_standard_concept_id AS prvisci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = prvisci.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   CONCAT('SOURCE=',prvisci.SOURCE,';INDEX=',prvisci.INDEX) = vo.visit_source_value AND
   prvisci.APPROX_EVENT_DAY = vo.visit_start_date
ORDER BY p.person_id, prvisci.APPROX_EVENT_DAY;
*/