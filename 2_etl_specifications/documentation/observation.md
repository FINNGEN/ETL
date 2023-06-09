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
        observation_concept_id
        observation_date
        observation_source_value
        observation_source_concept_id
        visit_occurrence_id
    end

    finngenid-->person_id
    omop_source_concept_id-->observation_concept_id
    approx_event_day-->observation_date
    code1-->observation_source_value
    omop_source_concept_id-->observation_source_concept_id
    source-->visit_occurrence_id
    index-->visit_occurrence_id
```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| observation_id |  |  | Generated:   Incremental integer.   Unique value per each row observation. |
| person_id | finngenid |  | Calculated:  person.person_id where person.person_source_value is stem.finngenid |
| observation_concept_id | omop_source_concept_id |  | Calculated:  From joining stem.omop_source_concept_id to cdm.concept_relationship.concept_id_2 "Maps to" concept_id for all events where standard code domain is observation or (when standard code domain is NULL and stem.default_domain LIKE obs).<br>  0 if not standard concept_id is found.<br>Note: If more than one standard concept_id maps to the non-standard one row is added per  standard concept_id |
| observation_date | approx_event_day |  | Calculated:  stem.approx_event_day |
| observation_datetime |  |  | Calculated:  observation.observation_date with time 00:00:0000 |
| observation_type_concept_id |  |  | Calculated:  Set 32879-Registry for all |
| value_as_number |  |  | Info not available:   set NULL |
| value_as_string |  |  | Info not available:   set NULL |
| value_as_concept_id |  |  | Info not available:   set 0 |
| qualifier_concept_id |  |  | Info not available:   set 0 |
| unit_concept_id |  |  | Info not available:   set 0 |
| provider_id |  |  | Same as parent visit_occurence.provider_id |
| visit_occurrence_id | source<br>index |  | Calculated:   Link to correspondent visit_occurence.visit_occurrence_id calulated from stem.source+stem.index. |
| visit_detail_id |  |  | Info not available:   set NULL |
| observation_source_value | code1 |  | Calculated:   Copy as it is in stem.code1 |
| observation_source_concept_id | omop_source_concept_id |  | Calculated:<br> If stem.omop_source_concept_id is not null then stem.omop_source_concept_id<br> Else 0 |
| unit_source_value |  |  | Info not available:   set NULL |
| qualifier_source_value |  |  | Info not available:   set NULL |
| value_source_value |  |  | Info not available:   set NULL |
| observation_event_id |  |  | Info not available:   set NULL |
| obs_event_field_concept_id |  |  | Info not available:   set 0 |

