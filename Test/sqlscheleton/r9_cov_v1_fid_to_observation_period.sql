
INSERT INTO observation_period
(
    observation_period_id,
    person_id,
    observation_period_start_date,
    observation_period_end_date,
    period_type_concept_id -- 32879 - Registry
)
SELECT
 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS observation_period_id,

    r9_cov_v1_fid.fid AS person_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS observation_period_start_date,

    r9_cov_v1_fid.age_at_death_or_end_of_followup AS observation_period_end_date,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS period_type_concept_id

FROM r9_cov_v1_fid
;