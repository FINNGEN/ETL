
INSERT INTO visit_occurrence
(
    visit_occurrence_id,
    person_id,
    visit_concept_id, -- For 'Day Surgery' IF       'CODE4' <=1 THEN 9202 'Outpaitnet Visit' irrespective of SOURCE        ELSE 'Day Surgery' is mapped to 'Inpatient Visit' 
    visit_concept_id, -- [!#WARNING!#] THIS TARGET FIELD WAS ALREADY USED -- For 'Day Surgery' IF       'CODE4' <=1 THEN 9202 'Outpaitnet Visit' irrespective of SOURCE        ELSE 'Day Surgery' is mapped to 'Inpatient Visit' 
    visit_start_date,
    visit_start_datetime, -- FORMAT_TIMESTAMP("%F %T",timestamp(approx_event_day))
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
SELECT
 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS visit_occurrence_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS person_id,

    prim_out.code5_contact_type AS visit_concept_id,

    prim_out.code6_service_sector AS visit_concept_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS visit_start_date,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS visit_start_datetime,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS visit_end_date,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS visit_end_datetime,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS visit_type_concept_id,

    prim_out.code7_professional_code AS provider_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS care_site_id,

    prim_out.source AS visit_source_value,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS visit_source_concept_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS admitted_from_concept_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS admitted_from_source_value,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS discharged_to_concept_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS discharged_to_source_value,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS preceding_visit_occurrence_id

FROM prim_out
;