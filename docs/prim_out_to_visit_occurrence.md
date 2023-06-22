---
title: prim_out to visit_occurrence
layout: default
parent: Prim_out
nav_order: 1
---

## hilmprim_outo to visit_occurrence

```mermaid
%%{init: {'theme': 'base' } }%%
%%{init: {'theme': 'base' } }%%
flowchart LR
    subgraph Source
        finngenid
        source
        approx_event_day
        code5_contact_type
        code6_service_sector
        code7_professional_code
        index
    end

    fg_codes_info[[fg_codes_info]]

    subgraph CDM-OMOP-v5.4
        person_id
        visit_start_date
        visit_end_date
        provider_id
        visit_source_value
        visit_source_concept_id
    end

    finngenid-->person_id
    index-->visit_source_value
    source-->visit_source_value
    approx_event_day-->visit_start_date
    approx_event_day-->visit_end_date
    code7_professional_code-->provider_id
    
    source-->fg_codes_info
    code5_contact_type-->fg_codes_info
    code6_service_sector-->fg_codes_info

    fg_codes_info-->visit_source_concept_id
    
    
```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| visit_occurrence_id |  | Incremental integer.<br> Unique value per combination of `source`+`index` | Generated |
| person_id | finngenid | `person_id` from person table where `person_source_value` equals `finngenid` | Calculated |
| visit_concept_id |  | `concept_id_2` from concept_relationship table where `concept_id_1` equals `visit_source_concept_id` and `relationship_id` equals "Maps to". | Calculated <br> NOTE: 0 when `visit_source_concept_id` is NULL |
| visit_start_date | approx_event_day | copied from `approx_event_day` | Calculated |
| visit_start_datetime |  | Calculated from  `visit_start_date` with time 00:00:0000 | Calculated |
| visit_end_date | approx_event_day | copied from `approx_event_day` | Calculated |
| visit_end_datetime |  | Calculated from  `visit_end_date` with time 00:00:0000 | Calculated|
| visit_type_concept_id |  | Set 32879  - 'Registry' for all | Calculated |
| provider_id | code7_professional_code | `provider_id` from provider table where `code7_professional_code` equals `speciality_source_value`. | Calculated <br>NOTE: There is only one `provider_id` per `code6_speciality` |
| care_site_id |  | Set 0 for all | Info not available |
| visit_source_value | source<br>index | String build as  "SOURCE=`source`;INDEX=`index`" | Calculated |
| visit_source_concept_id | source<br>code5_contact_type<br>code6_service_sector | `omop_concept_id` from fg_codes_info where `source` equals "PRIM_OUT" and `code5_contact_type` equals `fg_code5` and `code6_service_sector` equals `fg_code6` | Calculated using the fg_codes_info table.<br>NOTE: When no standard map is available then `source` equals "PRIM_OUT" |
| admitted_from_concept_id |  | Set 0 for all | Info not available |
| admitted_from_source_value |  | Set NULL for all | Info not available |
| discharged_to_concept_id |  | Set 0 for all | Info not available|
| discharged_to_source_value |  | Set NULL for all | Info not available |
| preceding_visit_occurrence_id |  | Set 0 for all | Info not available |
