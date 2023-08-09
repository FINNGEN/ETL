---
title: finngenid_info to visit_occurrence
layout: default
parent: Finngenid_info
nav_order: 3
---

## finngenid_info to visit_occurrence

```mermaid
%%{init: {'theme': 'base' } }%%
%%{init: {'theme': 'base' } }%%
flowchart LR
    subgraph Source
        finngenid
        bl_year
        bl_age
        approx_birth_date
    end

    subgraph CDM-OMOP-v5.4
        person_id
        visit_start_date
    end

    finngenid-->person_id
    bl_year-->visit_start_date
    bl_age-->visit_start_date
    approx_birth_date-->visit_start_date

```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| visit_occurrence_id |  | Incremental integer.<br> Unique value per combination of `source`+`index` | Generated |
| person_id | finngenid | `person_id` from person table where `person_source_value` equals `finngenid` | Calculated |
| visit_concept_id |  | `concept_id_2` from concept_relationship table where `concept_id_1` equals `visit_source_concept_id` and `relationship_id` equals "Maps to". | Calculated <br> NOTE: 0 when `visit_source_concept_id` is NULL |
| visit_start_date | bl_year<br>bl_age<br>approx_birth_date | `approx_event_day` is calculated as <br> If approx_birth_date is null and bl_year is not null then `visit_start_date` is simply bl_year.<br>Else `visit_start_date` is calulcated by adding bl_age to approx_birth_date. | Calculated |
| visit_start_datetime |  | Calculated from  `visit_start_date` with time 00:00:0000 | Calculated |
| visit_end_date |  | copied from `approx_event_day`  | Copied |
| visit_end_datetime |  | Calculated from  `visit_end_date` with time 00:00:0000 | Calculated|
| visit_type_concept_id |  | Set 32879  - 'Registry' for all | Calculated |
| provider_id |  | Set 0 for all | Info not available |
| care_site_id |  | Set 0 for all | Info not available |
| visit_source_value |  | String build as  "SOURCE=BIOBANK;INDEX=" | Calculated |
| visit_source_concept_id |  | `omop_concept_id` from fg_codes_info where `source` equals "BIOBANK" | Calculated using the fg_codes_info table. |
| admitted_from_concept_id |  | Set 0 for all | Info not available |
| admitted_from_source_value |  | Set NULL for all | Info not available |
| discharged_to_concept_id |  | Set 0 for all | Info not available|
| discharged_to_source_value |  | Set NULL for all | Info not available |
| preceding_visit_occurrence_id |  | Set 0 for all | Info not available |

