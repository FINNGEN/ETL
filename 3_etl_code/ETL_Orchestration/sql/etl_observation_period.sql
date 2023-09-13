-- DESCRIPTION:
-- Creates a row in cdm.observation.period table for each FinnGen id in the source.finngenid_info table.
-- cdm.observation_period.person_id is unique for each source.finngenid_info.finngenid.
-- It is calculated after joining by cdm.person.person_id table on cdm.person.person_source_value = source.finngenid_info.finngenid
--
--
-- PARAMETERS:
--
-- - schema_etl_input: schema with the etl input tables
-- - schema_cdm_output: schema with the output CDM tables

truncate table @schema_cdm_output.observation_period;

insert into @schema_cdm_output.observation_period
(
  	observation_period_id,
	person_id,
	observation_period_start_date,
	observation_period_end_date,
	period_type_concept_id
)
select
    row_number() over(order by p.person_id) as observation_period_id,
	p.person_id as person_id,
    case
		when p.year_of_birth >= 1953 then cast(p.birth_datetime as date)
		else cast('1953-01-01' as date)
	end as observation_period_start_date,
    case
		when fgi.fu_end_age is not null then dateadd(day, cast(fgi.fu_end_age * 365.25 as int), cast(p.birth_datetime as date))
		else cast('2023-01-15' as date)
	end as observation_period_end_date,
    32879 as period_type_concept_id
from @schema_cdm_output.person as p
join @schema_etl_input.finngenid_info as fgi
	on p.person_source_value = fgi.FINNGENID
-- order by p.person_id
;

/*
-- DESCRIPTION:
-- Creates a row in cdm.observation.period table for each FinnGen id in the source.finngenid_info table.
-- cdm.observation_period.person_id is unique for each source.finngenid_info.finngenid.
-- It is calculated after joining by cdm.person.person_id table on cdm.person.person_source_value = source.finngenid_info.finngenid
--
--
-- PARAMETERS:
--
-- - schema_etl_input: schema with the etl input tables
-- - schema_cdm_output: schema with the output CDM tables

TRUNCATE TABLE @schema_cdm_output.observation_period;
INSERT INTO @schema_cdm_output.observation_period
(
  observation_period_id,
  person_id,
  observation_period_start_date,
  observation_period_end_date,
  period_type_concept_id
)
SELECT
-- observation_period_id
    row_number()over(ORDER BY p.person_id) AS observation_period_id,
-- person_id
    p.person_id AS person_id,
-- observation_period_start_date
    CASE
        WHEN p.year_of_birth >= 1953 THEN CAST(p.birth_datetime AS DATE)
        ELSE CAST("1953-01-01" AS DATE)
    END AS observation_period_start_date,
-- observation_period_end_date
    CASE
        WHEN fgi.FU_END_AGE IS NOT NULL THEN DATE_ADD( CAST(p.birth_datetime AS DATE), INTERVAL CAST(fgi.FU_END_AGE * 365.25 AS INT64) DAY )
        ELSE CAST("2023-01-15" AS DATE)
    END AS observation_period_end_date,
-- period_type_concept_id
    32879 AS period_type_concept_id
--
FROM @schema_cdm_output.person AS p
JOIN @schema_etl_input.finngenid_info AS fgi
ON p.person_source_value = fgi.FINNGENID
ORDER BY p.person_id;
*/
