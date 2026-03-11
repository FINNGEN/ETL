---
title: spirometry to visit_occurrence
layout: default
parent: Spirometry
nav_order: 1
---

## spirometry to visit_occurrence

```mermaid
%%{init: {'theme': 'base' } }%%
%%{init: {'theme': 'base' } }%%
flowchart LR
    subgraph Source
        finngenid
        approx_date
        source
    end

    subgraph CDM-OMOP-v5.4
        person_id
        visit_start_datetime
        visit_source_value
    end

    finngenid-->person_id
    approx_date-->visit_start_datetime
    source-->visit_source_value

```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| visit_occurrence_id |  | Incremental integer.<br> Unique value per `finngenid` + 120000000000 (offset). | Generated |
| person_id | finngenid | `person_id` from person table where `person_source_value` equals `finngenid` | Calculated |
| visit_concept_id |  | `concept_id_2` from concept_relationship table where `concept_id_1` equals `visit_source_concept_id` and `relationship_id` equals "Maps to". | Calculated <br> NOTE: 0 when `visit_source_concept_id` is NULL |
| visit_start_date | approx_date | Copied `approx_date` directly. | Copied |
| visit_start_datetime |  | add 00:00:00 to `visit_start_date`  | Calculated |
| visit_end_date |  | copied from `visit_start_date`  | Copied |
| visit_end_datetime |  | copied from `visit_start_datetime` | Copied |
| visit_type_concept_id |  | Set 32879  - 'Registry' for all | Calculated |
| provider_id | coding_system_oid | `provider_id` from provider table where `coding_system_oid` equals `speciality_source_value`. |
| care_site_id |  | Set 0 for all | Info not available |
| visit_source_value | source | String build as  "SOURCE=`source`;INDEX=". | Calculated: <br> Process `source` by removing spaces with underscore and change to upper case like 'Auria Old Medikro' to 'AURIA_OLD_MEDIKRO' </br>|
| visit_source_concept_id |  | `omop_concept_id` from fg_codes_info where SOURCE equals `source` | Calculated using the fg_codes_info table. |
| admitted_from_concept_id |  | Set 0 for all | Info not available |
| admitted_from_source_value |  | Set NULL for all | Info not available |
| discharged_to_concept_id |  | Set 0 for all | Info not available|
| discharged_to_source_value |  | Set NULL for all | Info not available |
| preceding_visit_occurrence_id |  | Set 0 for all | Info not available |
