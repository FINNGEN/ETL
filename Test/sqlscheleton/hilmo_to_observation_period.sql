
INSERT INTO observation_period
(
    observation_period_id,
    person_id,
    observation_period_start_date,
    observation_period_start_date, -- [!#WARNING!#] THIS TARGET FIELD WAS ALREADY USED
    observation_period_end_date,
    observation_period_end_date, -- [!#WARNING!#] THIS TARGET FIELD WAS ALREADY USED
    period_type_concept_id -- 32879 - Registry
)
SELECT
 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS observation_period_id,

    hilmo.finngenid AS person_id,

    hilmo.event_age AS observation_period_start_date,

    hilmo.approx_event_day AS observation_period_start_date,

    hilmo.event_age AS observation_period_end_date,

    hilmo.approx_event_day AS observation_period_end_date,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS period_type_concept_id

FROM hilmo
;