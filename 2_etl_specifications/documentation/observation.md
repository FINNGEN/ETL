## Table name: observation

### Reading from stem_table

```mermaid
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
        observation_date
        observation_source_value
        observation_source_concept_id
        visit_occurrence_id
    end

    finngenid-->person_id
    approx_event_day-->observation_date
    code1-->observation_source_value
    omop_source_concept_id-->observation_source_concept_id
    source-->visit_occurrence_id
    index-->visit_occurrence_id
```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| observation_id |  | Incremental integer. Unique value per each row observation. | Generated |
| person_id | finngenid | `person_id` from person table where `person_source_value` equals `finngenid` |   Calculated |
| observation_concept_id |  | `concept_id_2` from concept_relationship table where `concept_id_1` equals `observation_source_concept_id` and `relationship_id` equals "Maps to" | Calculated <br> NOTE: IF a `observation_source_concept_id` has more than one standard mapping (`concept_id_2`), one row is added per each additional `observation_concept_id` |
| observation_date | approx_event_day | Copied from `approx_event_day` | Copied |
| observation_datetime |  | Calculated from  `observation_date` with time 00:00:0000 | Calculated |
| observation_type_concept_id |  | Set 32879 - 'Registry' for all | Calculated |
| value_as_number |  | Set NULL for all | Info not available |
| value_as_string |  | Set NULL for all | Info not available |
| value_as_concept_id |  | Set 0 for all | Info not available |
| qualifier_concept_id |  | Set 0 for all | Info not available |
| unit_concept_id |  | Set 0 for all | Info not available |
| provider_id |  | `provider_id` for mapped `visit_occurrence_id` from visit_occurrence table. | Calculated |
| visit_occurrence_id | source<br>index | Link to correspondent `visit_occurrence_id` from visit_occurrence table where `visit_source_value` equals "SOURCE=`source`;INDEX=`index`". | Calculated |
| visit_detail_id |  | Set NULL for all | Info not available |
| observation_source_value | code1 | Copied `code1` as it is | Copied |
| observation_source_concept_id | omop_source_concept_id | IF `omop_source_concept_id` is not null then `omop_source_concept_id`<br> ELSE 0 | Calculated |
| unit_source_value |  | Set NULL for all | Info not available |
| qualifier_source_value |  | Set NULL for all | Info not available |
| value_source_value |  | Set NULL for all | Info not available |
| observation_event_id |  | Set NULL for all | Info not available |
| obs_event_field_concept_id |  | Set 0 for all | Info not available |

