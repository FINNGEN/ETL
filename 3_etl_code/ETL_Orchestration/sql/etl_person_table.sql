-- DESCRIPTION:
-- Creates a row in cdm.person table for each FinnGen ID in the source.finngenid_info table.
--
-- PARAMETERS:
--
-- - schema_etl_input: schema with the etl input tables
-- - schema_cdm_output: schema with the output CDM tables

truncate table @schema_cdm_output.person;

insert into @schema_cdm_output.person
(
  person_id,
  gender_concept_id,
  year_of_birth,
  month_of_birth,
  day_of_birth,
  birth_datetime,
  race_concept_id,
  ethnicity_concept_id,
  location_id,
  provider_id,
  care_site_id,
  person_source_value,
  gender_source_value,
  gender_source_concept_id,
  race_source_value,
  race_source_concept_id,
  ethnicity_source_value,
  ethnicity_source_concept_id
)
select
    row_number()over(order by fgi.finngenid) as person_id,
    case 
        when fgi.sex = 'male' then 8507
        when fgi.sex = 'female' then 8532
        else 0
    end as gender_concept_id,
    case
        -- if approx_birth_date is null, subtract the age in years from the bl_year to infer the birth year
        when fgi.approx_birth_date is null and fgi.bl_year is not null and fgi.bl_age is not null then year(dateadd(day, -cast(fgi.bl_age * 365.25 as int), cast(cast(fgi.bl_year as varchar(255)) + '-01-01' as datetime)))
        else year(fgi.approx_birth_date)
    end as year_of_birth,
    case
        -- follows the same logic as for year_of_birth 
        when fgi.approx_birth_date is null and fgi.bl_year is not null and fgi.bl_age is not null then month(dateadd(day, -cast(fgi.bl_age * 365.25 as int), cast(cast(fgi.bl_year as varchar(255)) + '-01-01' as datetime)))
        else month(fgi.approx_birth_date)
    end as month_of_birth,
    case
        -- follows the same logic as for year_of_birth 
        when fgi.approx_birth_date is null and fgi.bl_year is not null and fgi.bl_age is not null then day(dateadd(day, -cast(fgi.bl_age * 365.25 as int), cast(cast(fgi.bl_year as varchar(255)) + '-01-01' as datetime)))
        else day(fgi.approx_birth_date)
    end as day_of_birth,
    case
        -- follows the same logic as for year_of_birth 
        when fgi.approx_birth_date is null and fgi.bl_year is not null and fgi.bl_age is not null then dateadd(day, -cast(fgi.bl_age * 365.25 as int), cast(cast(fgi.bl_year as varchar(255)) + '-01-01' as datetime))
        else fgi.approx_birth_date
    end as birth_datetime,
    0 as race_concept_id,
    0 as ethnicity_concept_id,
    null as location_id,
    null as provider_id,
    null as care_site_id,
    fgi.finngenid as person_source_value,
    fgi.sex as gender_source_value,
    0 as gender_source_concept_id,
    null as race_source_value,
    0 as race_source_concept_id,
    null as ethnicity_source_value,
    0 as ethnicity_source_concept_id
from @schema_etl_input.finngenid_info as fgi
-- order by fgi.finngenid
;
