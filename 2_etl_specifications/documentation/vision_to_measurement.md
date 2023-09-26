---
title: vision to measurement
layout: default
parent: Vision
nav_order: 4
---

## vision to measurement

```mermaid
%%{init: {'theme': 'base' } }%%
%%{init: {'theme': 'base' } }%%
flowchart LR
    subgraph Source
        finngenid
        event_age
        ohalk
        vhalk
    end

    subgraph CDM-OMOP-v5.4
        person_id
        measurement_date
        operator_concept_id
        value_as_number
    end


    finngenid-->person_id
    event_age-->measurement_date
    ohalk-->operator_concept_id
    ohalk-->value_as_number
    vhalk-->operator_concept_id
    vhalk-->value_as_number

```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| measurement_id |  | Incremental integer. Unique value per each row measurement + 111000000000 (offset) | Generated |
| person_id | finngenid | `person_id` from person table where `person_source_value` equals `finngenid` |   Calculated |
| measurement_concept_id |  | `concept_id_2` from concept_relationship table where `concept_id_1` equals `measurement_source_concept_id` and `relationship_id` equals "Maps to" and `domain_id` is "Measurement" | Calculated <br> NOTE: 0 when `measurement_source_concept_id` is NULL  |
| measurement_date | event_age | `approx_visit_date` is calculated as by adding event_age to approx_birth_date from finngenid_info table. | Calculated |
| measurement_datetime |  | Calculated from  `measurement_date` with time 00:00:0000 | Calculated |
| measurement_time |  | Set 00:00:0000 for all | Calculated |
| measurement_type_concept_id |  | Set 32879 - 'Registry' for all | Calculated |
| operator_concept_id | ohalk<br>vhalk | `concept_id` from concept table where `operator_vale` equals `concept_name` and  `domain_id` equals "Meas Value Operator".<br>0 if standard concept_id is not found.<br>`operator_value` is "=" for ohlak or vhalk equals 1,<br> "<=" for ohalk or vhalk in (2,3,4,5),<br> else ">" | Calculated |
| value_as_number | ohalk<br>vhalk | `value_as_number` is<br> 0 for ohlak or vhalk equals 1,<br> 5 when ohalk or vhalk equals 2,<br> 10 when ohalk or vhalk equals 3,<br>20 when ohalk or vhalk equals 4,<br>  else 60 | Calculated |
| value_as_concept_id |  | Set 0 for all | Info not available |
| unit_concept_id |  | `concept_id_2` from concept_relationship table where `concept_id_1` equals `unit_source_concept_id` and `relationship_id` equals "Maps to" and  `domain_id` equals "Unit".<br>0 if standard concept_id is not found.  | Calculated |
| range_low |  | Set NULL for all | Info not available |
| range_high |  | Set NULL for all | Info not available |
| provider_id |  | `provider_id` for mapped `visit_occurrence_id` from visit_occurrence table. | Calculated |
| visit_occurrence_id |  | Link to correspondent `visit_occurrence_id` from visit_occurrence table where `visit_source_value` equals "SOURCE=VISION;INDEX=". | Calculated |
| visit_detail_id |  | Set NULL for all | Info not available |
| measurement_source_value |  | When ohalk is not null then 'VFDRE' as SOURCE<br> When weight is null then 'VFDLE' as SOURCE | Calculated |
| measurement_source_concept_id |  | `omop_source_concept_id` from fg_codes_info where `source` IN ("VFDRE", "VFDLE") and `vocabulary_id` equals "FGvisitType" <br> ELSE 0 | Calculated |
| unit_source_value |  | "degrees of arc" | Calculated |
| unit_source_concept_id |  | `concept_id` from concept table where `concept_name` equals "degrees of arc" and `vocabulary_id` equals "SNOMED" and `domain_id` equals "Unit"<br> ELSE 0 | Calculated |
| value_source_value |  | Set NULL for all | Info not available |
| measurement_event_id |  | Set NULL for all | Info not available |
| meas_event_field_concept_id |  | Set 0 for all | Info not available |



