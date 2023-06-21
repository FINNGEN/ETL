-- DESCRIPTION:
-- Creates one row per finngenid in cdm.death table from the events in cdm.stem_medical_events.
-- Finds zero or more standard codes for each non-standard concept_id in cdm.stem_medical_events where SOURCE is DEATH.
-- Takes only these that map to a "measurement" [or is no mapping these where default_domain is a "measurement" NO SUCH CASES ATM].
-- Insert resulting events into the cdm.measurement table.
--
--
-- PARAMETERS:
--
-- - schema_etl_input: schema with the etl input tables
-- - schema_cdm_output: schema with the output CDM tables

truncate table @schema_cdm_output.death;
insert into @schema_cdm_output.death
(
  person_id,
  death_date,
  death_datetime,
  death_type_concept_id,
  cause_concept_id,
  cause_source_value,
  cause_source_concept_id
)

-- 1 - Get only Death events from registry DEATH
--   - Add standard concept id.
--   - Get one event per finngenid. If there is more than one event pero finngenid take highes base on CATEGORY following the ranking  I > U > c1 > c2 > c3 > c4
with death_from_registers_with_source_and_standard_concept_id as (
	select
		sme.*,
		cmap.concept_id_2,
		-- Priority of death events for each SOURCE+INDEX combination from which the one event needs to be selected
		-- Partition by SOURCE+INDEX
		-- Order by category I > U > c1 > c2 > c3 > c4
	    row_number() over (partition by sme.source, sme.index order by 
	    case category
	    	when 'I' then 1
			when 'U' then 2
			when 'c1' then 3
			when 'c2' then 4
			when 'c3' then 5
			when 'c4' then 6
			else 7
		end) as death_priority
	from @schema_etl_input.stem_medical_events as sme
	left join (
		select
			cr.concept_id_1,
			cr.concept_id_2,
			c.domain_id
		from
			@schema_vocab.concept_relationship as cr
		join @schema_vocab.concept as c
	  		on cr.concept_id_2 = c.concept_id
		where cr.relationship_id = 'Maps to'
	) as cmap
	on cast(sme.omop_source_concept_id as int) = cmap.concept_id_1
	where sme.source = 'DEATH'
)
-- 2 - Shape into death table
select
	p.person_id as person_id,
	dfrwsasci.approx_event_day as death_date,
  	cast(dfrwsasci.approx_event_day as datetime) as death_datetime,
  	32879 as death_type_concept_id,
  	coalesce(dfrwsasci.concept_id_2, 0) as cause_concept_id,
	dfrwsasci.code1 as cause_source_value,
	coalesce(cast(dfrwsasci.omop_source_concept_id as int), 0) as cause_source_concept_id
from death_from_registers_with_source_and_standard_concept_id as dfrwsasci
join @schema_cdm_output.person as p
	on p.person_source_value = dfrwsasci.finngenid
where dfrwsasci.death_priority = 1
-- order by person_id
;

/*
# DESCRIPTION:
# Creates one row per finngenid in cdm.death table from the events in cdm.stem_medical_events.
# Finds zero or more standard codes for each non-standard concept_id in cdm.stem_medical_events where SOURCE is DEATH.
# Takes only these that map to a "measurement" [or is no mapping these where default_domain is a "measurement" NO SUCH CASES ATM].
# Insert resulting events into the cdm.measurement table.
#
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

TRUNCATE TABLE @schema_cdm_output.death;
INSERT INTO @schema_cdm_output.death
(
  person_id,
  death_date,
  death_datetime,
  death_type_concept_id,
  cause_concept_id,
  cause_source_value,
  cause_source_concept_id
)

WITH
# 1 - Get only Death events from registry DEATH
#   - Add standard concept id.
#   - Get one event per finngenid. If there is more than one event pero finngenid take highes base on CATEORY following the ranking  I > U > c1 > c2 > c3 > c4
death_from_registers_with_source_and_standard_concept_id AS (
  SELECT sme.*,
         cmap.concept_id_2,
# Priority of death events for each SOURCE+INDEX combination from which the one event needs to be selected
# Partition by SOURCE+INDEX
# Order by category I > U > c1 > c2 > c3 > c4
         ROW_NUMBER() OVER (PARTITION BY sme.SOURCE, sme.INDEX
                            ORDER BY CASE CATEGORY
                                                   WHEN 'I' THEN 1
                                                   WHEN 'U' THEN 2
                                                   WHEN 'c1' THEN 3
                                                   WHEN 'c2' THEN 4
                                                   WHEN 'c3' THEN 5
                                                   WHEN 'c4' THEN 6
                                                   ELSE 7 END
                           ) AS death_priority
  FROM @schema_etl_input.stem_medical_events AS sme
  LEFT JOIN (
    SELECT cr.concept_id_1, cr.concept_id_2, c.domain_id
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to'
  ) AS cmap
  ON CAST(sme.omop_source_concept_id AS INT64) = cmap.concept_id_1
  # Here look for source DEATH
  WHERE sme.SOURCE = 'DEATH'
)

# 2 - Shape into death table
SELECT
# person_id
  p.person_id AS person_id,
# death_date
  dfrwsasci.APPROX_EVENT_DAY AS death_date,
# death_datetime
  DATETIME(TIMESTAMP(dfrwsasci.APPROX_EVENT_DAY)) AS death_datetime,
# death_type_concept_id
  32879 AS death_type_concept_id,
# cause_concept_id
  CASE
      WHEN dfrwsasci.concept_id_2 IS NOT NULL THEN dfrwsasci.concept_id_2
      ELSE 0
  END AS cause_concept_id,
# cause_source_value
  dfrwsasci.CODE1 AS cause_source_value,
# cause_source_concept_id
  CASE
    WHEN dfrwsasci.omop_source_concept_id IS NOT NULL THEN CAST(dfrwsasci.omop_source_concept_id AS INT64)
    ELSE 0
  END AS cause_source_concept_id
FROM death_from_registers_with_source_and_standard_concept_id AS dfrwsasci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = dfrwsasci.FINNGENID
WHERE dfrwsasci.death_priority = 1
ORDER BY person_id;
*/