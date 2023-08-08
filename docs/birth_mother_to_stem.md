---
title: birth_mother to stem
layout: default
parent: Birth_mother
nav_order: 2
---

## birth_mother to stem

```mermaid
%%{init: {'theme': 'base' } }%%
%%{init: {'theme': 'base' } }%%
flowchart LR
    subgraph Source
        rdiag1
        rdiag2
        rdiag3
        rdiag4
        rdiag5
        rdiag6
        rdiag7
        rdiag8
        rdiag9
        rdiag10
        sdiag1
        sdiag2
        sdiag3
        sdiag4
        sdiag5
        sdiag6
        sdiag7
        sdiag8
        sdiag9
        sdiag10
    end

    fg_codes_info[[fg_codes_info]]

    subgraph STEM
        omop_source_concept_id

    end

    rdiag1-->fg_codes_info
    rdiag2-->fg_codes_info
    rdiag3-->fg_codes_info
    rdiag4-->fg_codes_info
    rdiag5-->fg_codes_info
    rdiag6-->fg_codes_info
    rdiag7-->fg_codes_info
    rdiag8-->fg_codes_info
    rdiag9-->fg_codes_info
    rdiag10-->fg_codes_info
    sdiag1-->fg_codes_info
    sdiag2-->fg_codes_info
    sdiag3-->fg_codes_info
    sdiag4-->fg_codes_info
    sdiag5-->fg_codes_info
    sdiag6-->fg_codes_info
    sdiag7-->fg_codes_info
    sdiag8-->fg_codes_info
    sdiag9-->fg_codes_info
    sdiag10-->fg_codes_info

    fg_codes_info-->omop_source_concept_id
```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| finngenid | mother_finngenid | Copied as it is | Copied |
| source |  |  "BIRTH_MOTHER" | Calculated |
| approx_event_day | approx_event_day | Copied as it is | Copied |
| code1 | NEST(rdiag1 ... sdiag20) | If all 20 diagnosis codes are null then "Z37" default code is inserted<br>All non-null diagnosis codes extracted  | Copied |
| code2 |  | Set NULL for all | Info not available |
| code3 | | Set NULL for all | Info not available   |
| code4 | | Set NULL for all | Info not available   |
| category |  | Set NULL for all | Info not available |
| index |  | Empty string | Calculated |
| code |  |`code` from fg_codes_info where `vocabulary_id`=`vocabulary_id` `code1`=`fg_code1` and `code2`=`fg_code2` | Calculated|
| vocabulary_id |  |  If `code1` starts with 0-9 then `vocabulary_id` is "ICD9fi". <br> ELSE `vocabulary_id` is "ICD10fi". | Calculated |
| omop_source_concept_id | | `omop_concept_id` from fg_codes_info where `vocabulary_id`=`vocabulary_id` and `code1`=`fg_code1` and `code2`=`fg_code2` | Calculated|
| default_domain |  | Default domain is "condition" | Calculated |
