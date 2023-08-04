-- DESCRIPTION:
-- Creates a row in cdm-visit occurrence table for each event of FinnGen id in the longitudinal data.
-- Person id is extracted from person table
--
-- PARAMETERS:
--
-- - schema_etl_input: schema with the etl input tables
-- - schema_cdm_output: schema with the output CDM tables

truncate table @schema_cdm_output.visit_occurrence;
insert into @schema_cdm_output.visit_occurrence
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

-- 1- Collect one row per visit per register with necesary columns
with purch as (
	select
		row_number() over(partition by source, index order by approx_event_day desc) as q1,
		finngenid,
		source,
		approx_event_day,
		approx_event_day as approx_end_day,
		code5_reimbursement as code5,
		code6_additional_reimbursement as code6,
		code7_reimbursement_category as code7,
		null as code8,
		null as code9,
		index
	from
		@schema_etl_input.purch
), hilmo as (
	select
		row_number() over(partition by source, index order by approx_event_day desc) as q1,
		finngenid,
		source,
		approx_event_day,
		case
			when code4_hospital_days_na is not null 
				and cast(code4_hospital_days_na as int) >= 1 then cast(dateadd(day,
				cast(code4_hospital_days_na as int), approx_event_day) as date)
			else approx_event_day
		end as approx_end_day,
		code5_service_sector as code5,
		code6_speciality as code6,
		code7_hospital_type as code7,
		code8_contact_type as code8,
		code9_urgency as code9,
		index
	from
		@schema_etl_input.hilmo
), prim_out as (
	select
		row_number() over(partition by source, index order by approx_event_day desc) as q1,
		finngenid,
		source,
		approx_event_day,
		approx_event_day as approx_end_day,
		code5_contact_type as code5,
		code6_service_sector as code6,
		code7_professional_code as code7,
		null as code8,
		null as code9,
		index
	from
		@schema_etl_input.prim_out
), reimb as (
	select 
		row_number() over(partition by source, index order by approx_event_day desc) as q1,
		finngenid,
		source,
		approx_event_day,
		approx_event_day as approx_end_day,
		null as code5,
		null as code6,
		null as code7,
		null as code8,
		null as code9,
		index
	from
		@schema_etl_input.reimb
), canc as (
	select
		row_number() over(partition by source, index order by approx_event_day desc) as q1,
		finngenid,
		source,
		approx_event_day,
		approx_event_day as approx_end_day,
		null as code5,
		null as code6,
		null as code7,
		null as code8,
		null as code9,
		index
	from
		@schema_etl_input.canc
), death_register as (
	select
		row_number() over(partition by source, index order by approx_event_day desc) as q1,
		finngenid,
		source,
		approx_event_day,
		approx_event_day as approx_end_day,
		null as code5,
		null as code6,
		null as code7,
		null as code8,
		null as code9,
		index
	from
		@schema_etl_input.death_register
), visits_from_registers as (
	select * from purch where q1 = 1
	union all
	select * from hilmo where q1 = 1
	union all 
	select * from prim_out where q1 = 1
	union all 
	select * from reimb where q1 = 1
	union all 
	select * from canc where q1 = 1
	union all 
	select * from death_register where q1 = 1
),
-- 2- append visit type using script in finngenutilsr
-- 2-1 process the visit codes to get visit_type from fg_codes_info_v2 table
visit_type_fg_codes_preprocessed as (
	select
		finngenid,
		source,
		approx_event_day,
		approx_end_day,
		code5,
		code6,
		code7,
		code8,
		code9,
		index,
		case
			when source = 'PRIM_OUT' then code5
			when source in ('INPAT', 'OUTPAT', 'OPER_IN', 'OPER_OUT', 'PRIM_OUT') and code8 is null and code9 is null then code5
			else null
		end as fg_code5,
		case
			when source = 'PRIM_OUT' then code6
			else null
		end as fg_code6,
		case
			when source in ('INPAT', 'OUTPAT', 'OPER_IN', 'OPER_OUT') and (code8 is not null or code9 is not null) then code8
			else null
		end as fg_code8,
		case
			when source in ('INPAT', 'OUTPAT', 'OPER_IN', 'OPER_OUT') and (code8 is not null or code9 is not null) then code9
			else null
		end as fg_code9
	from
		visits_from_registers
),
-- 2-2 append visit type from fg_codes_info_v2 table based on condition
-- 2-2 change the processed codes for which visit_type_omop_concept_id is null
visits_from_registers_with_source_visit_type_id as (
	select
		vtfgpre.finngenid,
		vtfgpre.source,
		vtfgpre.approx_event_day,
		vtfgpre.approx_end_day,
		vtfgpre.code5,
		vtfgpre.fg_code5,
		vtfgpre.code6,
		vtfgpre.fg_code6,
		vtfgpre.code7,
		vtfgpre.code8,
		vtfgpre.fg_code8,
		vtfgpre.code9,
		vtfgpre.fg_code9,
		vtfgpre.index,
		fgc.omop_concept_id as visit_type_omop_concept_id
	from
		visit_type_fg_codes_preprocessed as vtfgpre
	left join (
		select
			source,
			fg_code5,
			fg_code6,
			fg_code8,
			fg_code9,
			omop_concept_id
		from
			@schema_table_codes_info
		where
			vocabulary_id = 'FGVisitType') as fgc
		/*
		 * Original implementation with bigquery used 'is not distinct from' operator
		 * which returns true if both operands are equal or both are NULL and
		 * which does not exist in ms sql server format. The same result can be
		 * achieved by using a combination of the '=' operator and the 'is null' condition.
		 */
		on (vtfgpre.source = fgc.source or (vtfgpre.source is null and fgc.source is null))
		and (vtfgpre.fg_code5 = fgc.fg_code5 or (vtfgpre.fg_code5 is null and fgc.fg_code5 is null))
		and (vtfgpre.fg_code6 = fgc.fg_code6 or (vtfgpre.fg_code6 is null and fgc.fg_code6 is null))
		and (vtfgpre.fg_code8 = fgc.fg_code8 or (vtfgpre.fg_code8 is null and fgc.fg_code8 is null))
		and (vtfgpre.fg_code9 = fgc.fg_code9 or (vtfgpre.fg_code9 is null and fgc.fg_code9 is null))
),
-- 3- add standard_visit_type_id and
--    change the source value when the standard concept is null to parent visittype based on source
visits_from_registers_with_source_and_standard_visit_type_id as (
	select distinct
	    vfrwsvti.finngenid,
		vfrwsvti.source,
		vfrwsvti.approx_event_day,
		vfrwsvti.approx_end_day,
		vfrwsvti.code6,
		vfrwsvti.code7,
		vfrwsvti.index,
		case
			when ssmap.concept_id_2 is null and vfrwsvti.source in ('INPAT', 'OUTPAT', 'OPER_IN', 'OPER_OUT', 'PRIM_OUT') then null
			else vfrwsvti.visit_type_omop_concept_id
		end as visit_type_omop_concept_id,
		case
			when ssmap.concept_id_2 is null and vfrwsvti.source in ('INPAT', 'OUTPAT', 'OPER_IN', 'OPER_OUT', 'PRIM_OUT') then null
			else vfrwsvti.fg_code5
		end as fg_code5,
		case
			when ssmap.concept_id_2 is null and vfrwsvti.source = 'PRIM_OUT' then null
			else vfrwsvti.fg_code6
		end as fg_code6,
		case
			when ssmap.concept_id_2 is null and vfrwsvti.source in ('INPAT', 'OUTPAT', 'OPER_IN', 'OPER_OUT') then null
			else vfrwsvti.fg_code8
		end as fg_code8,
		case
			when ssmap.concept_id_2 is null and vfrwsvti.source in ('INPAT', 'OUTPAT', 'OPER_IN', 'OPER_OUT') then null
			else vfrwsvti.fg_code9
		end as fg_code9
	from
		visits_from_registers_with_source_visit_type_id as vfrwsvti
	left join (
		select
			cr.concept_id_1,
			cr.concept_id_2,
			c.concept_name
		from
			@schema_vocab.concept_relationship as cr
		join @schema_vocab.concept as c
	    on
			cr.concept_id_2 = c.concept_id
		where
			cr.relationship_id = 'Maps to'
			and c.domain_id in ('Visit', 'Metadata')
	  ) as ssmap
	  on
		cast(vfrwsvti.visit_type_omop_concept_id as int) = ssmap.concept_id_1
),
-- 4- add the non-standard code
visits_from_registers_with_source_and_standard_visit_type_null_id as (
	select
		vfrwssti.finngenid,
		vfrwssti.source,
		vfrwssti.approx_event_day,
		vfrwssti.approx_end_day,
		vfrwssti.code6,
		vfrwssti.code7,
		vfrwssti.index,
		fgc.omop_concept_id as visit_type_omop_concept_id
	from
		visits_from_registers_with_source_and_standard_visit_type_id as vfrwssti
	left join (
		select
			source,
			fg_code5,
			fg_code6,
			fg_code8,
			fg_code9,
			omop_concept_id
		from
			@schema_table_codes_info
		where
			vocabulary_id = 'FGVisitType') as fgc
		/*
		 * Original implementation with bigquery used 'is not distinct from' operator
		 * which returns true if both operands are equal or both are NULL and
		 * which does not exist in ms sql server format. The same result can be
		 * achieved by using a combination of the '=' operator and the 'is null' condition.
		 */
		on (vfrwssti.source = fgc.source or (vfrwssti.source is null and fgc.source is null))
		and (vfrwssti.fg_code5 = fgc.fg_code5 or (vfrwssti.fg_code5 is null and fgc.fg_code5 is null))
		and (vfrwssti.fg_code6 = fgc.fg_code6 or (vfrwssti.fg_code6 is null and fgc.fg_code6 is null))
		and (vfrwssti.fg_code8 = fgc.fg_code8 or (vfrwssti.fg_code8 is null and fgc.fg_code8 is null))
		and (vfrwssti.fg_code9 = fgc.fg_code9 or (vfrwssti.fg_code9 is null and fgc.fg_code9 is null))
),
-- 5- add the standard concept id again
visits_from_registers_with_source_and_standard_visit_type_full as (
	select
		*
	from
		visits_from_registers_with_source_and_standard_visit_type_null_id as vfrwssvtni
	left join (
		select
			cr.concept_id_1,
			cr.concept_id_2,
			c.concept_name
		from
			@schema_vocab.concept_relationship as cr
		join @schema_vocab.concept as c
	    	on cr.concept_id_2 = c.concept_id
		where
			cr.relationship_id = 'Maps to'
			and c.domain_id in ('Visit', 'Metadata')
	  ) as ssmap
	  on cast(vfrwssvtni.visit_type_omop_concept_id as int) = ssmap.concept_id_1
    -- remove hilmo inpat visits that are inpatient with ndays = 1
    -- or outpatient with ndays>1
	where not (
    	(
	    vfrwssvtni."source" in ('INPAT', 'OPER_IN')
		and vfrwssvtni.approx_event_day = vfrwssvtni.approx_end_day
		and (ssmap.concept_name like 'Inpatient%'
			or ssmap.concept_name like 'Rehabilitation%'
			or ssmap.concept_name like 'Other%'
			or ssmap.concept_name like 'Substance%'
			or ssmap.concept_name like 'Emergency Room and Inpatient Visit%')
		)
		
		or 
		
		(
	    vfrwssvtni."source" in ('INPAT', 'OPER_IN')
		and vfrwssvtni.approx_event_day < vfrwssvtni.approx_end_day
		and (ssmap.concept_name like 'Outpatient%'
			or ssmap.concept_name like 'Ambulatory%'
			or ssmap.concept_name like 'Home%'
			or ssmap.concept_name like 'Emergency Room Visit%'
			or ssmap.concept_name like 'Case Management Visit%')
	    )
	)
)
-- 6- shape into visit_occurrence_table
select
  	row_number() over(order by vfrwssvtf.source, vfrwssvtf.index) as visit_occurrence_id,
	p.person_id as person_id,
	coalesce(vfrwssvtf.concept_id_2, 0) as visit_concept_id,
	vfrwssvtf.approx_event_day as visit_start_date,
	cast(vfrwssvtf.approx_event_day as datetime) as visit_start_datetime,
	vfrwssvtf.approx_end_day as visit_end_date,
	cast(vfrwssvtf.approx_end_day as datetime) as visit_end_datetime,
  	32879 as visit_type_concept_id,
	/*
	case
		when provider.provider_id is not null then provider.provider_id
		else 0
	end as provider_id,
	*/
	provider.provider_id as provider_id,
  	null as care_site_id,
	concat('SOURCE=',vfrwssvtf.source,';INDEX=',vfrwssvtf.index) as visit_source_value,
	coalesce(cast(vfrwssvtf.visit_type_omop_concept_id as int), 0) as visit_source_concept_id,
  	0 as admitted_from_concept_id,
  	null as admitted_from_source_value,
  	0 as discharged_to_concept_id,
  	null as discharged_to_source_value,
  	null as preceding_visit_occurrence_id
from visits_from_registers_with_source_and_standard_visit_type_full as vfrwssvtf
join @schema_cdm_output.person as p
	on p.person_source_value = vfrwssvtf.finngenid
/*
left join @schema_cdm_output.provider as provider
	on	case
			when vfrwssvtf.source in ('INPAT', 'OUTPAT', 'OPER_IN', 'OPER_OUT') then vfrwssvtf.code6 = provider.specialty_source_value
			when vfrwssvtf.source = 'PRIM_OUT' then vfrwssvtf.CODE7 = provider.specialty_source_value
			else null
		end
*/
left join (
select
	fg_code6,
	fg_code7,
	omop_concept_id
from
	@schema_table_codes_info
where
	vocabulary_id in ('MEDSPECfi', 'ProfessionalCode')
) as fgcp
on case
		when vfrwssvtf.source in ('INPAT', 'OUTPAT', 'OPER_IN', 'OPER_OUT') then vfrwssvtf.code6 = fgcp.fg_code6
		when vfrwssvtf.source = 'PRIM_OUT' then vfrwssvtf.code7 = fgcp.fg_code7
		else null
	end
left join @schema_cdm_output.provider as provider
	on cast(fgcp.omop_concept_id as int) = provider.specialty_source_concept_id
;

/*
# DESCRIPTION:
# Creates a row in cdm-visit occurrence table for each event of FinnGen id in the longitudinal data.
# Person id is extracted from person table
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables


TRUNCATE TABLE @schema_cdm_output.visit_occurrence;
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


WITH
# 1- Collect one row per visit per register with necesary columns
visits_from_registers AS (
# PURCH
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      APPROX_EVENT_DAY AS approx_end_day,
      CODE5_REIMBURSEMENT AS CODE5,
      CODE6_ADDITIONAL_REIMBURSEMENT AS CODE6,
      CODE7_REIMBURSEMENT_CATEGORY AS CODE7,
      CAST(NULL AS STRING) AS CODE8,
      CAST(NULL AS STRING) AS CODE9,
      INDEX
    FROM @schema_etl_input.purch
  )
  WHERE q1 = 1
  UNION ALL
# HILMO
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      CASE
        WHEN CODE4_HOSPITAL_DAYS_NA IS NOT NULL AND CAST(CODE4_HOSPITAL_DAYS_NA AS INT64) >= 1 THEN  DATE_ADD(APPROX_EVENT_DAY, INTERVAL CAST(CODE4_HOSPITAL_DAYS_NA AS INT64) DAY)
        ELSE APPROX_EVENT_DAY
      END AS approx_end_day,
      CODE5_SERVICE_SECTOR AS CODE5,
      CODE6_SPECIALITY AS CODE6,
      CODE7_HOSPITAL_TYPE AS CODE7,
      CODE8_CONTACT_TYPE AS CODE8,
      CODE9_URGENCY AS CODE9,
      INDEX
    FROM @schema_etl_input.hilmo
  )
  WHERE q1 = 1
  UNION ALL
# PRIM_OUT
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      APPROX_EVENT_DAY AS approx_end_day,
      CODE5_CONTACT_TYPE AS CODE5,
      CODE6_SERVICE_SECTOR AS CODE6,
      CODE7_PROFESSIONAL_CODE AS CODE7,
      CAST(NULL AS STRING) AS CODE8,
      CAST(NULL AS STRING) AS CODE9,
      INDEX
    FROM @schema_etl_input.prim_out
  )
  WHERE q1 = 1
  UNION ALL
# REIMB
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      APPROX_EVENT_DAY AS approx_end_day,
      CAST(NULL AS STRING) AS CODE5,
      CAST(NULL AS STRING) AS CODE6,
      CAST(NULL AS STRING) AS CODE7,
      CAST(NULL AS STRING) AS CODE8,
      CAST(NULL AS STRING) AS CODE9,
      INDEX
    FROM @schema_etl_input.reimb
  )
  WHERE q1 = 1
  UNION ALL
# CANC
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      APPROX_EVENT_DAY AS approx_end_day,
      CAST(NULL AS STRING) AS CODE5,
      CAST(NULL AS STRING) AS CODE6,
      CAST(NULL AS STRING) AS CODE7,
      CAST(NULL AS STRING) AS CODE8,
      CAST(NULL AS STRING) AS CODE9,
      INDEX
    FROM @schema_etl_input.canc
  )
  WHERE q1 = 1
  UNION ALL
# DEATH
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      APPROX_EVENT_DAY AS approx_end_day,
      CAST(NULL AS STRING) AS CODE5,
      CAST(NULL AS STRING) AS CODE6,
      CAST(NULL AS STRING) AS CODE7,
      CAST(NULL AS STRING) AS CODE8,
      CAST(NULL AS STRING) AS CODE9,
      INDEX
    FROM @schema_etl_input.death_register
  )
  WHERE q1 = 1
),

# 2- append visit type using script in FinnGenUtilsR
# 2-1 Process the visit codes to get visit_type from fg_codes_info_v2 table
visit_type_fg_codes_preprocessed AS (
  SELECT
    FINNGENID,
    SOURCE,
    APPROX_EVENT_DAY,
    approx_end_day,
    CODE5,
    CODE6,
    CODE7,
    CODE8,
    CODE9,
    INDEX,
    CASE
        WHEN SOURCE = 'PRIM_OUT' THEN CODE5
        WHEN SOURCE IN ('INPAT','OUTPAT','OPER_IN', 'OPER_OUT', 'PRIM_OUT') AND CODE8 IS NULL AND CODE9 IS NULL THEN CODE5
        ELSE NULL
    END AS FG_CODE5,
    CASE
        WHEN SOURCE = 'PRIM_OUT' THEN CODE6
        ELSE NULL
    END AS FG_CODE6,
    CASE
        WHEN SOURCE IN ('INPAT','OUTPAT','OPER_IN', 'OPER_OUT')  AND (CODE8 IS NOT NULL OR CODE9 IS NOT NULL) THEN CODE8
        ELSE NULL
    END AS FG_CODE8,
    CASE
        WHEN SOURCE IN ('INPAT','OUTPAT','OPER_IN', 'OPER_OUT') AND (CODE8 IS NOT NULL OR CODE9 IS NOT NULL) THEN CODE9
        ELSE NULL
    END AS FG_CODE9
  FROM visits_from_registers
),
# 2-2 append visit type from fg_codes_info_v2 table based on condition
# 2-2 Change the processed codes for which visit_type_omop_concept_id iS NULL
visits_from_registers_with_source_visit_type_id AS (
  SELECT vtfgpre.FINNGENID,
         vtfgpre.SOURCE,
         vtfgpre.APPROX_EVENT_DAY,
         vtfgpre.approx_end_day,
         vtfgpre.CODE5, vtfgpre.FG_CODE5,
         vtfgpre.CODE6, vtfgpre.FG_CODE6,
         vtfgpre.CODE7,
         vtfgpre.CODE8, vtfgpre.FG_CODE8,
         vtfgpre.CODE9, vtfgpre.FG_CODE9,
         vtfgpre.INDEX,
         fgc.omop_concept_id AS visit_type_omop_concept_id
  FROM visit_type_fg_codes_preprocessed AS vtfgpre
  LEFT JOIN ( SELECT SOURCE,
                     FG_CODE5,
                     FG_CODE6,
                     FG_CODE8,
                     FG_CODE9,
                     omop_concept_id
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'FGVisitType') AS fgc
  ON vtfgpre.SOURCE IS NOT DISTINCT FROM fgc.SOURCE AND
     vtfgpre.FG_CODE5 IS NOT DISTINCT FROM fgc.FG_CODE5 AND
     vtfgpre.FG_CODE6 IS NOT DISTINCT FROM fgc.FG_CODE6 AND
     vtfgpre.FG_CODE8 IS NOT DISTINCT FROM fgc.FG_CODE8 AND
     vtfgpre.FG_CODE9 IS NOT DISTINCT FROM fgc.FG_CODE9
),

# 3- add standard_visit_type_id and
#    change the source value when the standard concept is null to parent VisitType based on SOURCE
visits_from_registers_with_source_and_standard_visit_type_id AS (
  SELECT DISTINCT
         vfrwsvti.FINNGENID,
         vfrwsvti.SOURCE,
         vfrwsvti.APPROX_EVENT_DAY,
         vfrwsvti.approx_end_day,
         vfrwsvti.CODE6,
         vfrwsvti.CODE7,
         vfrwsvti.INDEX,
         CASE
              WHEN ssmap.concept_id_2 IS NULL AND vfrwsvti.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT','PRIM_OUT') THEN NULL
              ELSE vfrwsvti.visit_type_omop_concept_id
         END AS visit_type_omop_concept_id,
         CASE
              WHEN ssmap.concept_id_2 IS NULL AND vfrwsvti.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT','PRIM_OUT')  THEN NULL
              ELSE vfrwsvti.FG_CODE5
         END AS FG_CODE5,
         CASE
              WHEN ssmap.concept_id_2 IS NULL AND vfrwsvti.SOURCE = 'PRIM_OUT' THEN NULL
              ELSE vfrwsvti.FG_CODE6
         END AS FG_CODE6,
         CASE
              WHEN ssmap.concept_id_2 IS NULL AND vfrwsvti.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') THEN NULL
              ELSE vfrwsvti.FG_CODE8
         END AS FG_CODE8,
         CASE
              WHEN ssmap.concept_id_2 IS NULL AND vfrwsvti.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') THEN NULL
              ELSE vfrwsvti.FG_CODE9
         END AS FG_CODE9
  FROM visits_from_registers_with_source_visit_type_id AS vfrwsvti
  LEFT JOIN (
    SELECT cr.concept_id_1, cr.concept_id_2, c.concept_name
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id IN ('Visit','Metadata')
  ) AS ssmap
  ON
    CAST(vfrwsvti.visit_type_omop_concept_id AS INT64) = ssmap.concept_id_1
),

# 4- Add the non-standard code
visits_from_registers_with_source_and_standard_visit_type_null_id AS (
  SELECT vfrwssti.FINNGENID,
         vfrwssti.SOURCE,
         vfrwssti.APPROX_EVENT_DAY,
         vfrwssti.approx_end_day,
         vfrwssti.CODE6,
         vfrwssti.CODE7,
         vfrwssti.INDEX,
         fgc.omop_concept_id AS visit_type_omop_concept_id
  FROM visits_from_registers_with_source_and_standard_visit_type_id AS vfrwssti
  LEFT JOIN ( SELECT SOURCE,
                     FG_CODE5,
                     FG_CODE6,
                     FG_CODE8,
                     FG_CODE9,
                     omop_concept_id
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'FGVisitType') AS fgc
  ON vfrwssti.SOURCE IS NOT DISTINCT FROM fgc.SOURCE AND
     vfrwssti.FG_CODE5 IS NOT DISTINCT FROM fgc.FG_CODE5 AND
     vfrwssti.FG_CODE6 IS NOT DISTINCT FROM fgc.FG_CODE6 AND
     vfrwssti.FG_CODE8 IS NOT DISTINCT FROM fgc.FG_CODE8 AND
     vfrwssti.FG_CODE9 IS NOT DISTINCT FROM fgc.FG_CODE9
),

# 5- Add the standard concept id again
visits_from_registers_with_source_and_standard_visit_type_full AS (
  SELECT *
  FROM visits_from_registers_with_source_and_standard_visit_type_null_id AS vfrwssvtni
  LEFT JOIN (
    SELECT cr.concept_id_1, cr.concept_id_2, c.concept_name
    FROM @schema_vocab.concept_relationship AS cr
      JOIN @schema_vocab.concept AS c
      ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id IN ('Visit','Metadata')
  ) AS ssmap
  ON
    CAST(vfrwssvtni.visit_type_omop_concept_id AS INT64) = ssmap.concept_id_1
    # remove hilmo inpat visits that are inpatient with ndays=1 or ourtpatient with ndays>1
  WHERE NOT ( (vfrwssvtni.SOURCE IN ('INPAT','OPER_IN') AND
               vfrwssvtni.APPROX_EVENT_DAY = vfrwssvtni.approx_end_day AND
               REGEXP_CONTAINS(ssmap.concept_name,r'^(Inpatient|Rehabilitation|Other|Substance|Emergency Room and Inpatient Visit)'))
              OR
              (vfrwssvtni.SOURCE IN ('INPAT','OPER_IN') AND
               vfrwssvtni.APPROX_EVENT_DAY < vfrwssvtni.approx_end_day AND
               REGEXP_CONTAINS(ssmap.concept_name,r'^(Outpatient|Ambulatory|Home|Emergency Room Visit|Case Management Visit)')) )
)

# 6- shaper into visit_occurrence_table
SELECT
# visit_occurrence_id
  ROW_NUMBER() OVER( ORDER BY vfrwssvtf.SOURCE, vfrwssvtf.INDEX) AS visit_occurrence_id,
#person_id,
  p.person_id AS person_id,
#visit_concept_id,
  CASE
    WHEN vfrwssvtf.concept_id_2 IS NOT NULL THEN vfrwssvtf.concept_id_2
    ELSE 0
  END AS visit_concept_id,
#visit_start_date,
  vfrwssvtf.APPROX_EVENT_DAY AS visit_start_date,
#visit_start_datetime,
  DATETIME(TIMESTAMP(vfrwssvtf.APPROX_EVENT_DAY)) AS visit_start_datetime,
#visit_end_date,
  vfrwssvtf.approx_end_day AS approx_end_day,
#visit_end_datetime,
  DATETIME(TIMESTAMP(vfrwssvtf.approx_end_day)) AS approx_end_day,
#visit_type_concept_id,
  32879 AS visit_type_concept_id,
#provider_id,
#  CASE
#    WHEN provider.provider_id IS NOT NULL THEN provider.provider_id
#    ELSE 0
#  END AS provider_id,
  provider.provider_id AS provider_id,
#care_site_id,
  NULL AS care_site_id,
#visit_source_value,
  CONCAT('SOURCE=',vfrwssvtf.SOURCE,';INDEX=',vfrwssvtf.INDEX) AS visit_source_value,
#visit_source_concept_id,
  CASE
    WHEN vfrwssvtf.visit_type_omop_concept_id IS NOT NULL THEN CAST(vfrwssvtf.visit_type_omop_concept_id AS INT64)
    ELSE 0
  END AS visit_source_concept_id,
#admitted_from_concept_id,
  0 AS admitted_from_concept_id,
#admitted_from_source_value,
  CAST(NULL AS STRING) AS admitted_from_source_value,
#discharged_to_concept_id,
  0 AS discharged_to_concept_id,
#discharged_to_source_value,
  CAST(NULL AS STRING) AS discharged_to_source_value,
#preceding_visit_occurrence_id
  NULL AS preceding_visit_occurrence_id,
#
FROM visits_from_registers_with_source_and_standard_visit_type_full AS vfrwssvtf
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = vfrwssvtf.FINNGENID
#LEFT JOIN @schema_cdm_output.provider AS provider
#ON CASE
#       WHEN vfrwssvtf.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') THEN vfrwssvtf.CODE6 = provider.specialty_source_value
#       WHEN vfrwssvtf.SOURCE = 'PRIM_OUT' THEN vfrwssvtf.CODE7 = provider.specialty_source_value
#       ELSE NULL
#   END
LEFT JOIN ( SELECT FG_CODE6,
                   FG_CODE7,
                   omop_concept_id
            FROM @schema_table_codes_info
            WHERE vocabulary_id IN ('MEDSPECfi','ProfessionalCode')
          ) AS fgcp
ON CASE
        WHEN vfrwssvtf.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') THEN vfrwssvtf.CODE6 = fgcp.FG_CODE6
        WHEN vfrwssvtf.SOURCE = 'PRIM_OUT' THEN vfrwssvtf.CODE7 = fgcp.FG_CODE7
        ELSE NULL
   END
LEFT JOIN @schema_cdm_output.provider AS provider
ON CAST(fgcp.omop_concept_id AS INT64) = provider.specialty_source_concept_id
;
*/
