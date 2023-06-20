## Table name: device_exposure

### Reading from stem_table

```mermaid
%%{init: {'theme': 'base' } }%%
flowchart LR
    subgraph Source
        finngenid
        source
        approx_event_day
        code1
        index
        omop_source_concept_id
    end

    subgraph CDM-OMOP-v5.4
        person_id
        device_exposure_start_date
        device_exposure_end_date
        device_source_value
        device_source_concept_id
        visit_occurrence_id
    end

    finngenid-->person_id
    approx_event_day-->device_exposure_start_date
    approx_event_day-->device_exposure_end_date
    source-->visit_occurrence_id
    index-->visit_occurrence_id
    code1-->device_source_value
    omop_source_concept_id-->device_source_concept_id
```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| device_exposure_id |  | Incremental integer. Unique value per each row device. | Generated |
| person_id | finngenid | `person_id` from person table where `person_source_value` equals `finngenid` |   Calculated |
| device_concept_id |  | `concept_id_2` from concept_relationship table where `concept_id_1` equals `device_source_concept_id` and `relationship_id` equals "Maps to" | Calculated <br> NOTE: IF a `device_source_concept_id` has more than one standard mapping (`concept_id_2`), one row is added per each additional `device_concept_id` |
| device_exposure_start_date | approx_event_day | Copied from `approx_event_day` | Copied|
| device_exposure_start_datetime |  | Calculated from  `device_exposure_start_date` with time 00:00:0000 | Calculated |
| device_exposure_end_date | approx_event_day | Copied from `approx_event_day` | Copied <br> NOTE: There is no `device_exposure_end_date` in the source data, it is set same as `device_exposure_start_date` |
| device_exposure_end_datetime |  | Calculated from  `device_exposure_end_date` with time 00:00:0000 | Calculated |
| device_type_concept_id |  | Set 32879 - 'Registry' for all | Calculated |
| unique_device_id |  | Set NULL for all | Info not available |
| production_id |  | Set NULL for all | Info not available |
| quantity | quantity | Set NULL for all | Info not available |
| provider_id |  | `provider_id` for mapped `visit_occurrence_id` from visit_occurrence table. | Calculated |
| visit_occurrence_id | source<br>index | Link to correspondent `visit_occurrence_id` from visit_occurrence table where `visit_source_value` equals "SOURCE=`source`;INDEX=`index`". | Calculated |
| visit_detail_id |  | set NULL for all | Info not available |
| device_source_value | code1 | Copied `code1` as it is | Copied |
| device_source_concept_id | omop_source_concept_id | IF `omop_source_concept_id` is not null then `omop_source_concept_id`<br> ELSE 0 | Calculated |
| unit_concept_id |  | Set 0 for all | Info not available |
| unit_source_value |  | Set NULL for all | Info not available |
| unit_source_concept_id |  | Set 0 for all | Info not available |

