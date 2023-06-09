## Table name: drug_exposure

### Reading from purch

```mermaid
flowchart LR
    subgraph Source
        finngenid
        source
        approx_event_day
        code3_vnro
        code4_plkm
        index
    end

    subgraph CDM-OMOP-v5.4
        person_id
        drug_concept_id
        drug_exposure_start_date
        drug_exposure_end_date
        quantity
        drug_source_value
        drug_source_concept_id
        visit_occurrence_id
    end

    finngenid-->person_id
    code3_vnro-->drug_concept_id
    approx_event_day-->drug_exposure_start_date
    approx_event_day-->drug_exposure_end_date
    code4_plkm-->quantity
    source-->visit_occurrence_id
    index-->visit_occurrence_id
    code3_vnro-->drug_source_value
    code3_vnro-->drug_source_concept_id

```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| drug_exposure_id |  |  | Generated:   Incremental integer.   Unique value per each row drug_exposure for each source.person.person_id |
| person_id | finngenid |  | Calculated:  person.person_id where person.person_source_value is source.purch.finngenid |
| drug_concept_id | code3_vnro |  | Calculated:  Extract medical_codes.fg_codes_info.omop_source_concept_id when source.code3_vnro is medical_codes.fg_codes_info.fg_code1.<br> When medical_codes.fg_codes_info.omop_source_concept_id is cdm.concept_relationship.concept_id_1 for relationship_id "Maps to" then standard concept_id is extracted.<br>  0 if not standard concept_id is found. |
| drug_exposure_start_date | approx_event_day |  | Calculated:  source.purch.approx_event_day |
| drug_exposure_start_datetime |  |  | Calculated:  drug_exposure.drug_exposure_start_date with time 00:00:0000. |
| drug_exposure_end_date | approx_event_day |  |  Calculated:  source.purch.approx_event_day |
| drug_exposure_end_datetime |  |  | Calculated:  drug_exposure.drug_exposure_end_date with time 00:00:0000. |
| verbatim_end_date |  |  | Info not available:   set NULL for all |
| drug_type_concept_id |  |  | Calculated:  Set 32879-Registry for all |
| stop_reason |  |  | Info not available:   set NULL for all |
| refills |  |  | Info not available:   set NULL for all |
| quantity | code4_plkm |  | Calculated:<br> If source.code4_plkm is not NULL then source.code4_plkm.<br>ELSE NULL |
| days_supply |  |  | Info not available:  Set to 1 for all |
| sig |  |  | Calculated:   Copied from finngen_vnr_v1.MedicineNameFull |
| route_concept_id |  |  | Calculated:  From vocabulary tables |
| lot_number |  |  | Info not available:  set NULL |
| provider_id |  |  | Same as parent visit_occurence.provider_id |
| visit_occurrence_id | index<br>source |  | Calculated:   Link to correspondent visit_occurence.visit_occurrence_id calulated from SOURCE+INDEX. |
| visit_detail_id |  |  | Info not available:  set NULL |
| drug_source_value | code3_vnro |  | Calculated:   Copy as it is in LPAD(purch.code3_vnro,6,'0') |
| drug_source_concept_id | code3_vnro |  | Calculated:<br>  Extract medical_codes.fg_codes_info.omop_source_concept_id when source.code3_vnro is medical_codes.fg_codes_info.fg_code1.<br> 0 when no such connection exists |
| route_source_value |  |  | Info not available:  set NULL |
| dose_unit_source_value |  |  | Info not available:  set NULL |