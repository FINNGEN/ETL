
INSERT INTO drug_exposure
(
    drug_exposure_id,
    person_id,
    drug_concept_id,
    drug_exposure_start_date,
    drug_exposure_start_datetime,
    drug_exposure_end_date,
    drug_exposure_end_datetime,
    verbatim_end_date,
    drug_type_concept_id,
    stop_reason,
    refills,
    quantity,
    days_supply,
    sig,
    route_concept_id,
    lot_number,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    drug_source_value,
    drug_source_concept_id,
    route_source_value,
    dose_unit_source_value
)
SELECT
 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS drug_exposure_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS person_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS drug_concept_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS drug_exposure_start_date,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS drug_exposure_start_datetime,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS drug_exposure_end_date,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS drug_exposure_end_datetime,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS verbatim_end_date,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS drug_type_concept_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS stop_reason,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS refills,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS quantity,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS days_supply,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS sig,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS route_concept_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS lot_number,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS provider_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS visit_occurrence_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS visit_detail_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS drug_source_value,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS drug_source_concept_id,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS route_source_value,

 -- [!WARNING!] no source column found. See possible comment at the INSERT INTO
    NULL AS dose_unit_source_value

FROM purch
;