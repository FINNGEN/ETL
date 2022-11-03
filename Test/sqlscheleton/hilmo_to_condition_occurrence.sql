
INSERT INTO condition_occurrence
(
    condition_occurrence_id,
    person_id,
    condition_concept_id,
    condition_start_date,
    condition_start_datetime,
    condition_end_date,
    condition_end_date, -- [!#WARNING!#] THIS TARGET FIELD WAS ALREADY USED
    condition_end_datetime,
    condition_end_datetime, -- [!#WARNING!#] THIS TARGET FIELD WAS ALREADY USED
    condition_type_concept_id,
    condition_status_concept_id,
    stop_reason,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    condition_source_value,
    condition_source_value, -- [!#WARNING!#] THIS TARGET FIELD WAS ALREADY USED
    condition_source_value, -- [!#WARNING!#] THIS TARGET FIELD WAS ALREADY USED
    condition_source_concept_id,
    condition_status_source_value
)
SELECT
 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS condition_occurrence_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS person_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS condition_concept_id,

    hilmo.approx_event_day AS condition_start_date,

    hilmo.approx_event_day AS condition_start_datetime,

    hilmo.approx_event_day AS condition_end_date,

    hilmo.code4_hospital_days_na AS condition_end_date,

    hilmo.approx_event_day AS condition_end_datetime,

    hilmo.code4_hospital_days_na AS condition_end_datetime,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS condition_type_concept_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS condition_status_concept_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS stop_reason,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS provider_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS visit_occurrence_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS visit_detail_id,

    hilmo.code1_icd_symptom_operation_code AS condition_source_value,

    hilmo.code2_icd_cause_na AS condition_source_value,

    hilmo.code3_atc_code_na AS condition_source_value,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS condition_source_concept_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS condition_status_source_value

FROM hilmo
;