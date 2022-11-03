
INSERT INTO death
(
    person_id,
    death_date,
    death_datetime,
    death_type_concept_id,
    cause_concept_id,
    cause_source_value,
    cause_source_concept_id
)
SELECT
 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS person_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS death_date,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS death_datetime,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS death_type_concept_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS cause_concept_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS cause_source_value,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS cause_source_concept_id

FROM death
;