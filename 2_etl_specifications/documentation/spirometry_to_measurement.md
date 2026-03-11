---
title: spirometry to measurement
layout: default
parent: Spirometry
nav_order: 2
---

## spirometry to measurement

```mermaid
%%{init: {'theme': 'base' } }%%
%%{init: {'theme': 'base' } }%%
flowchart LR
    subgraph Source
        finngenid
        approx_date
        source
        fev1_best
        fvc_best
        fev1_fvc_ratio
        fev1_post
        fvc_post
        fev1_fvc_post
        fev1_change_pct
        fvc_change_pct
    end

    fg_codes_info[[fg_codes_info]]

    subgraph CDM-OMOP-v5.4
        person_id
        measurement_date
        measurement_source_concept_id
        unit_source_concept_id        
        value_as_number
        visit_occurrence_id
    end

    finngenid-->person_id
    approx_date-->measurement_date
    source-->visit_occurrence_id

    fev1_best-->fg_codes_info
    fvc_best-->fg_codes_info
    fev1_fvc_ratio-->fg_codes_info
    fev1_post-->fg_codes_info
    fvc_post-->fg_codes_info
    fev1_fvc_post-->fg_codes_info
    fev1_change_pct-->fg_codes_info
    fvc_change_pct-->fg_codes_info

    fg_codes_info-->measurement_source_concept_id
    fg_codes_info-->unit_source_concept_id

    fev1_best-->value_as_number
    fvc_best-->value_as_number
    fev1_fvc_ratio-->value_as_number
    fev1_post-->value_as_number
    fvc_post-->value_as_number
    fev1_fvc_post-->value_as_number
    fev1_change_pct-->value_as_number
    fvc_change_pct-->value_as_number
    
```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| measurement_id |  | Incremental integer. Unique value per each row measurement + 121000000000 (offset) | Generated |
| person_id | finngenid | `person_id` from person table where `person_source_value` equals `finngenid` |   Calculated |
| measurement_concept_id |  | `concept_id_2` from concept_relationship table where `concept_id_1` equals `measurement_source_concept_id` and `relationship_id` equals "Maps to" and `domain_id` is "Measurement" | Calculated <br> NOTE: 0 when `measurement_source_concept_id` is NULL  |
| measurement_date | approx_date | copied from `approx_date` for all | Copied |
| measurement_datetime |  | add 00:00:00 to `measurement_date`  | Calculated |
| measurement_time |  | extract time from `measurement_datetime` for all | Calculated |
| measurement_type_concept_id |  | Set 32879 - 'Registry' for all | Calculated |
| operator_concept_id |  | Set 0 for all | Calculated |
| value_as_number | fev1_best<br>fvc_best<br>fev1_fvc_ratio<br>fev1_post<br>fvc_post<br>fev1_fvc_post<br>fev1_change_pct<br>fvc_change_pct | Copied directly from variables| Copied <br> NOTE: `value_as_number` can be NULL |
| value_as_concept_id |  | Set 0 for all | Info not available |
| unit_concept_id |  | `concept_id_2` from concept_relationship table where `concept_id_1` equals `unit_source_concept_id` and `relationship_id` equals "Maps to" and  `domain_id` equals "Unit".<br>0 if standard concept_id is not found.  | Calculated |
| range_low |  | Set NULL for all | Info not available |
| range_high |  | Set NULL for all | Info not available |
| provider_id |  | `provider_id` for mapped `visit_occurrence_id` from visit_occurrence table. | Calculated |
| visit_occurrence_id | source | Link to correspondent `visit_occurrence_id` from visit_occurrence table where `visit_source_value` equals "SOURCE=`source`;INDEX=". | Calculated |
| visit_detail_id |  | Set NULL for all | Info not available |
| measurement_source_value | fev1_best<br>fvc_best<br>fev1_fvc_ratio<br>fev1_post<br>fvc_post<br>fev1_fvc_post<br>fev1_change_pct<br>fvc_change_pct | Names of the variables as it is | Copied |
| measurement_source_concept_id | fev1_best<br>fvc_best<br>fev1_fvc_ratio<br>fev1_post<br>fvc_post<br>fev1_fvc_post<br>fev1_change_pct<br>fvc_change_pct | `omop_concept_id` from fg_codes_info where `vocabulary_id` IN ("FGVisitType") and `measurement_source_value` equals `code` <br> ELSE 0 | Calculated |
| unit_source_value |  | Set as `l` for fev1_best, fev1_post, fvc_best and fvc_post. Rest is set to NULL | Calculated |
| unit_source_concept_id |  | `omop_concept_id` from fg_codes_info where `vocabulary_id` IN ("UNITfi") and `unit_source_value` equals `code` <br> ELSE 0 | Calculated |
| value_source_value |  | Set NULL for all | Info not available |
| measurement_event_id |  | Set NULL for all | Info not available |
| meas_event_field_concept_id |  | Set 0 for all | Info not available |



