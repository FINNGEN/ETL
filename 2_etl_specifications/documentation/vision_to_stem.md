---
title: vision to stem
layout: default
parent: Vision
nav_order: 2
---

## vision to stem

```mermaid
%%{init: {'theme': 'base' } }%%
%%{init: {'theme': 'base' } }%%
flowchart LR
    subgraph Source
        diagn1
        diagn2
        diagn3
        diagn4
        ovisus
        vvisus
        ohemia
        vhemia
    end

    fg_codes_info[[fg_codes_info]]

    subgraph STEM
        omop_source_concept_id

    end

    diagn1-->fg_codes_info
    diagn2-->fg_codes_info
    diagn3-->fg_codes_info
    diagn2-->fg_codes_info
    ovisus-->fg_codes_info
    vvisus-->fg_codes_info
    ohemia-->fg_codes_info
    vhemia-->fg_codes_info

    fg_codes_info-->omop_source_concept_id
```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| finngenid | finngenid | Copied as it is | Copied |
| source |  |  "VISION" | Calculated |
| approx_event_day | event_age | `approx_visit_date` is calculated as by adding event_age to approx_birth_date from finngenid_info table. | Calculated |
| code1 | NEST(diagn1 ... diagn4)<br>ovisus<br>ohemia<br>vhemia | All non-null diagnosis codes extracted and code should not be H5442.<br>Only certain combinations of ovisus and vvisus are considered:<br> ovisus IN (6,7,8,9) AND vvisus IN (1,2,3,4,5) <br>ovisus IN (1,2,3,4,5) AND vvisus IN (6,7,8,9) <br>ovisus = 6 AND vvisus IN (7,8,9) <br>ovisus IN (7,8,9) AND vvisus = 6 <br>ovisus = 7 AND vvisus IN (8,9) <br>ovisus IN (8,9) AND vvisus = 7 <br> ohemia should be 1 <br> vhemia should be 1 | Copied <br> NOTE: `vision` table is a wide format (one column per diagnose). It is transformed to long format when converted to the `stem` table (one row per not null diagnose)   |
| code2 | vvisus | Only certain combinations of ovisus and vvisus are considered:<br> ovisus IN (6,7,8,9) AND vvisus IN (1,2,3,4,5) <br>ovisus IN (1,2,3,4,5) AND vvisus IN (6,7,8,9) <br>ovisus = 6 AND vvisus IN (7,8,9) <br>ovisus IN (7,8,9) AND vvisus = 6 <br>ovisus = 7 AND vvisus IN (8,9) <br>ovisus IN (8,9) AND vvisus = 7 | Copied |
| code3 | | Set NULL for all | Info not available   |
| code4 | | Set NULL for all | Info not available   |
| category |  | Set NULL for all | Info not available |
| index |  | Empty string | Calculated |
| code |  |`code` from fg_codes_info  | Calculated|
| vocabulary_id |  |  If `code1` equals "0544C" then `vocabulary_id` is "ICD9fi".<br> If `code1` starts with 0-9 then `vocabulary_id` is "ICD9CM". <br> ELSE `vocabulary_id` is "ICD10fi". | Calculated |
| omop_source_concept_id | | For diagnosis columns:<br>`omop_concept_id` from fg_codes_info where<br> `vocabulary_id`=`vocabulary_id` and <br>`code1`=`fg_code1` and<br> `code2`=`fg_code2` and<br> `code3`=`fg_code3` <br> For ovisus, vvisus, ohemia and vhemia columns:<br> `omop_concept_id` from fg_codes_info where<br> `SOURCE`=`SOURCE` and <br>`code1`=`fg_code1` and<br> `code2`=`fg_code2` and<br> `code3`=`fg_code3` | Calculated|
| default_domain |  | Default domain is "condition" | Calculated |
