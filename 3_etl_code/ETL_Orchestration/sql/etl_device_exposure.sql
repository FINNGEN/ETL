-- DESCRIPTION:
-- Creates a row in cdm.device_exposure table for each device event in the cdm.stem_medical_events.
-- Finds zero or more standard code for each non-standard concept_id in cdm.stem_medical_events.
-- Takes only these that map to a "device" [or is no mapping these where default_domain is a "device" NO SUCH CASES ATM].
-- Insert resulting events into the cdm.device_exposure table.
--
-- PARAMETERS:
--
-- - schema_etl_input: schema with the etl input tables
-- - schema_cdm_output: schema with the output CDM tables

truncate table @schema_cdm_output.device_exposure;
insert into @schema_cdm_output.device_exposure
(
  device_exposure_id,
  person_id,
  device_concept_id,
  device_exposure_start_date,
  device_exposure_start_datetime,
  device_exposure_end_date,
  device_exposure_end_datetime,
  device_type_concept_id,
  unique_device_id,
  production_id,
  quantity,
  provider_id,
  visit_occurrence_id,
  visit_detail_id,
  device_source_value,
  device_source_concept_id,
  unit_concept_id,
  unit_source_value,
  unit_source_concept_id
)

-- 1 - Get only "Device" events, as define form standard code or using default domain
-- Join stem_medical_events.omop_concept_id to zero or more "Device" standard codes in vocab.concept_relationship table
-- Take these with "Device" standard mappings or with default_mapping contains "Device"
with device_exposure_from_registers_with_source_and_standard_concept_id as (
  select sme.*,
         cmap.concept_id_2
  from @schema_etl_input.stem_medical_events as sme
  left join (
    select cr.concept_id_1, cr.concept_id_2, c.domain_id
    from @schema_vocab.concept_relationship as cr
    join @schema_vocab.concept as c
    on cr.concept_id_2 = c.concept_id
    where cr.relationship_id = 'Maps to' and c.domain_id ='Device'
  ) as cmap
  on cast(sme.omop_source_concept_id as int) = cmap.concept_id_1
  where cmap.domain_id = 'Device'  or  (cmap.domain_id is null and sme.default_domain like '%Device%')
)

-- 2 - Shape into device exposure table
select
  row_number() over(order by defrwsasci.source, defrwsasci.index) as device_exposure_id,
  p.person_id as person_id,
  coalesce(defrwsasci.concept_id_2, 0),
  defrwsasci.approx_event_day as device_exposure_start_date,
  cast(defrwsasci.approx_event_day as datetime) as device_exposure_start_datetime,
  defrwsasci.approx_event_day as device_exposure_end_date,
  cast(defrwsasci.approx_event_day as datetime) as device_exposure_end_datetime,
  32879 as device_type_concept_id,
  null as unique_device_id,
  null as production_id,
  null as quantity,
  vo.provider_id as provider_id,
  vo.visit_occurrence_id as visit_occurrence_id,
  null as visit_detail_id,
  defrwsasci.code1 as device_source_value,
  coalesce(cast(defrwsasci.omop_source_concept_id as int), 0) device_source_concept_id,
  0 as unit_concept_id,
  null as unit_source_value,
  0 as unit_source_concept_id
from device_exposure_from_registers_with_source_and_standard_concept_id as defrwsasci
join @schema_cdm_output.person as p
on p.person_source_value = defrwsasci.finngenid
join @schema_cdm_output.visit_occurrence as vo
on vo.person_id = p.person_id and
   'SOURCE=' + defrwsasci.source + ';INDEX=' + defrwsasci.index = vo.visit_source_value and
   defrwsasci.approx_event_day = vo.visit_start_date
order by person_id, device_exposure_id;


/*
# DESCRIPTION:
# Creates a row in cdm.device_exposure table for each device event in the cdm.stem_medical_events.
# Finds zero or more standard code for each non-standard concept_id in cdm.stem_medical_events.
# Takes only these that map to a "device" [or is no mapping these where default_domain is a "device" NO SUCH CASES ATM].
# Insert resulting events into the cdm.device_exposure table.
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

TRUNCATE TABLE @schema_cdm_output.device_exposure;
INSERT INTO @schema_cdm_output.device_exposure
(
  device_exposure_id,
  person_id,
  device_concept_id,
  device_exposure_start_date,
  device_exposure_start_datetime,
  device_exposure_end_date,
  device_exposure_end_datetime,
  device_type_concept_id,
  unique_device_id,
  production_id,
  quantity,
  provider_id,
  visit_occurrence_id,
  visit_detail_id,
  device_source_value,
  device_source_concept_id,
  unit_concept_id,
  unit_source_value,
  unit_source_concept_id
)

WITH
# 1 - Get only "Device" events, as define form standard code or using default domain
# Join stem_medical_events.omop_concept_id to zero or more "Device" standard codes in vocab.concept_relationship table
# Take these with "Device" standard mappings or with default_mapping contains "Device"
device_exposure_from_registers_with_source_and_standard_concept_id AS (
  SELECT sme.*,
         cmap.concept_id_2
  FROM @schema_etl_input.stem_medical_events AS sme
  LEFT JOIN (
    SELECT cr.concept_id_1, cr.concept_id_2, c.domain_id
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id ='Device'
  ) AS cmap
  ON CAST(sme.omop_source_concept_id AS INT64) = cmap.concept_id_1
  # Here look for default domain device and standard domain to be device
  #WHERE sme.default_domain LIKE '%Device%' AND (cmap.domain_id = 'Device' OR cmap.domain_id IS NULL)
  WHERE cmap.domain_id = 'Device'  OR  (cmap.domain_id IS NULL AND sme.default_domain LIKE '%Device%')
)

# 2 - Shape into device exposure table
SELECT
# device_exposure_id
  ROW_NUMBER() OVER(ORDER by defrwsasci.SOURCE, defrwsasci.INDEX) AS device_exposure_id,
# person_id
  p.person_id AS person_id,
# device_concept_id
  CASE
      WHEN defrwsasci.concept_id_2 IS NOT NULL THEN defrwsasci.concept_id_2
      ELSE 0
  END AS device_concept_id,
# device_exposure_start_date
  defrwsasci.APPROX_EVENT_DAY AS device_exposure_start_date,
# device_exposure_start_datetime
  DATETIME(TIMESTAMP(defrwsasci.APPROX_EVENT_DAY)) AS device_exposure_start_datetime,
# device_exposure_end_date
  defrwsasci.APPROX_EVENT_DAY AS device_exposure_end_date,
# device_exposure_end_datetime
  DATETIME(TIMESTAMP(defrwsasci.APPROX_EVENT_DAY)) AS device_exposure_end_datetime,
# device_type_concept_id
  32879 AS device_type_concept_id,
# unique_device_id
  CAST(NULL AS STRING) AS unique_device_id,
# production_id
  CAST(NULL AS STRING) AS production_id,
# quantity
  NULL AS quantity,
# provider_id
  vo.provider_id AS provider_id,
# visit_occurrence_id
  vo.visit_occurrence_id AS visit_occurrence_id,
# visit_detail_id
  NULL AS visit_detail_id,
# device_source_value
  defrwsasci.CODE1 AS device_source_value,
# device_source_concept_id
  CASE
    WHEN defrwsasci.omop_source_concept_id IS NOT NULL THEN CAST(defrwsasci.omop_source_concept_id AS INT64)
    ELSE 0
  END AS device_source_concept_id,
# unit_concept_id
  0 AS unit_concept_id,
# unit_source_value
  CAST(NULL AS STRING) AS unit_source_value,
# unit_source_concept_id
  0 AS unit_source_concept_id
FROM device_exposure_from_registers_with_source_and_standard_concept_id AS defrwsasci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = defrwsasci.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   CONCAT('SOURCE=',defrwsasci.SOURCE,';INDEX=',defrwsasci.INDEX) = vo.visit_source_value AND
   defrwsasci.APPROX_EVENT_DAY = vo.visit_start_date
ORDER BY person_id, device_exposure_id;
*/