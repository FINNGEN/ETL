## Table name: procedure_occurrence

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
        procedure_date
        procedure_end_date
        procedure_source_value
        procedure_source_concept_id
        visit_occurrence_id
    end

    finngenid-->person_id
    approx_event_day-->procedure_date
    approx_event_day-->procedure_end_date
    source-->visit_occurrence_id
    index-->visit_occurrence_id
    code1-->procedure_source_value
    omop_source_concept_id-->procedure_source_concept_id
```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| procedure_occurrence_id |  |    Incremental integer.   Unique value per each row procedure_occurence. | Generated |
| person_id | finngenid | `person_id` from person table where `person_source_value` equals `finngenid` |   Calculated|
| procedure_concept_id |  | `concept_id_2` from concept_relationship table where `concept_id_1` equals `procedure_source_concept_id` and `relationship_id` equals "Maps to" | Calculated <br> NOTE: IF a `procedure_source_concept_id` has more than one standard mapping (`concept_id_2`), one row is added per each additional `procedure_concept_id` |
| procedure_date | approx_event_day | Copied from `approx_event_day` | Copied |
| procedure_datetime |  | Calculated from  `procedure_date` with time 00:00:0000 | Calculated |
| procedure_end_date | approx_event_day | Copied from `approx_event_day` | Copied <br> NOTE: There is no `procedure_end_date` in the source data, it is set same as `procedure_date` |
| procedure_end_datetime |  | Calculated from  `procedure_end_date` with time 00:00:0000 | Calculated |
| procedure_type_concept_id |  | Set 32879 - 'Registry' for all | Calculated |
| modifier_concept_id |  | Set 0 for all | Info not available.<br>NOTE: Info potentially available: Perhaps the some nomesco codes should be mapped to modifier vocabulary and used in here. To discuse with FinOMOP. |
| quantity |  | Set 1 for all | Calculated |
| provider_id |  | `provider_id` for mapped `visit_occurrence_id` from visit_occurrence table. | Calculated |
| visit_occurrence_id | source<br>index | Link to correspondent `visit_occurrence_id` from visit_occurrence table where `visit_source_value` equals "SOURCE=`source`;INDEX=`index`". | Calculated |
| visit_detail_id |  | set NULL for all | Info not available |
| procedure_source_value | code1 | Copied `code1` as it is | Copied |
| procedure_source_concept_id | omop_source_concept_id | IF `omop_source_concept_id` is not null then `omop_source_concept_id`<br> ELSE 0 | Calculated |
| modifier_source_value |  | Set NULL for all | Info not available |

