
INSERT INTO person
(
    person_id,
    gender_concept_id, -- case sex WHEN LOWER('MALE') then 8507                WHEN LOWER('FEMALE') then 8532                WHEN 'NA' then NULL
    year_of_birth, -- EXTRACT( YEAR FROM birth_datetime)
    year_of_birth, -- [!#WARNING!#] THIS TARGET FIELD WAS ALREADY USED -- EXTRACT( YEAR FROM birth_datetime)
    month_of_birth, -- EXTRACT( DAY FROM birth_datetime)
    month_of_birth, -- [!#WARNING!#] THIS TARGET FIELD WAS ALREADY USED -- EXTRACT( DAY FROM birth_datetime)
    day_of_birth,
    day_of_birth, -- [!#WARNING!#] THIS TARGET FIELD WAS ALREADY USED
    birth_datetime, -- FORMAT_TIMESTAMP("%F %T",timestamp(DATE_SUB(APPROX_EVENT_DAY, INTERVAL CAST(EVENT_AGE AS INT64) YEAR))) AS birth_datetime Pick the lowest grouped by FINNGENID
    birth_datetime, -- [!#WARNING!#] THIS TARGET FIELD WAS ALREADY USED -- FORMAT_TIMESTAMP("%F %T",timestamp(DATE_SUB(APPROX_EVENT_DAY, INTERVAL CAST(EVENT_AGE AS INT64) YEAR))) AS birth_datetime Pick the lowest grouped by FINNGENID
    race_concept_id, -- 4005076, FINNS
    ethnicity_concept_id, -- 38003564 - Not Hispanic or Latino
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
SELECT
 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS person_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS gender_concept_id,

    hilmo.event_age AS year_of_birth,

    hilmo.approx_event_day AS year_of_birth,

    hilmo.event_age AS month_of_birth,

    hilmo.approx_event_day AS month_of_birth,

    hilmo.event_age AS day_of_birth,

    hilmo.approx_event_day AS day_of_birth,

    hilmo.event_age AS birth_datetime,

    hilmo.approx_event_day AS birth_datetime,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS race_concept_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS ethnicity_concept_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS location_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS provider_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS care_site_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS person_source_value,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS gender_source_value,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS gender_source_concept_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS race_source_value,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS race_source_concept_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS ethnicity_source_value,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS ethnicity_source_concept_id

FROM hilmo
;