---
title: finngenid_info to person
layout: default
parent: Finngenid_info
nav_order: 1
---

## finngenid_info to person

```mermaid
%%{init: {'theme': 'base' } }%%
%%{init: {'theme': 'base' } }%%
flowchart LR
    subgraph Source
        finngenid
        bl_year
        bl_age
        approx_birth_date
        sex
        
    end

    subgraph CDM-OMOP-v5.4
        person_id
        gender_concept_id
        birth_datetime
        person_source_value
        gender_source_value
    end


    finngenid-->person_id
    finngenid-->person_source_value
    bl_year --> birth_datetime
    bl_age --> birth_datetime
    approx_birth_date --> birth_datetime
    sex --> gender_concept_id
    sex --> gender_source_value
    
```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| person_id | finngenid |  Incremental integer.  <br> Unique `person_id` per each `finngenid` | Generated |
| gender_concept_id | sex |   If `sex` is 'male' then `gender_concept_id` is 8507 <br>  If `sex` is 'female' then `gender_concept_id` is 8532 <br> other wise 0 | Calculated|
| year_of_birth |  |   Calculated from `person.birth_datetime` | Calculated |
| month_of_birth |  | Calculated from `person.birth_datetime` | Calculated |
| day_of_birth |  | Calculated from `person.birth_datetime` | Calculated|
| birth_datetime | approx_birth_date<br>bl_year<br>bl_age | Copied from `approx_birth_date` <br>  If `approx_birth_date` is null then `birth_datetime` is calculated substracting `bl_age` from `bl_year` | Calculated|
| race_concept_id |  | Set 0 for all | Info not available |
| ethnicity_concept_id |  | Set 0 for all | Info not available|
| location_id |  | Set 0 for all | Info potentially available:  <br> Possibly in `source.finngenid_info.regionofbirth` |
| provider_id |  |  Set 0 for all | Info not available|
| care_site_id |  | Set 0 for all | Info not available |
| person_source_value | finngenid | Verbatim from `finngenid` | Calculated|
| gender_source_value | sex | Verbatim from `sex` | Calculated |
| gender_source_concept_id | | Set 0 for all | Info not available |
| race_source_value |  | Set NULL for all | Info not available | 
| race_source_concept_id | |  Set 0 for all| Info not available |
| ethnicity_source_value | | Set NULL for all | Info not available|
| ethnicity_source_concept_id | | Set 0 for all. | Info not available |

