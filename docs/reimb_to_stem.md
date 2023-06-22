---
title: reimb to stem
layout: default
parent: Reimb
nav_order: 2
---

## reimb to stem

```mermaid
%%{init: {'theme': 'base' } }%%
%%{init: {'theme': 'base' } }%%
flowchart LR
    subgraph Source
        code1_kela_disease
        code2_icd
        icdver
    end

    fg_codes_info[[fg_codes_info]]

    subgraph STEM
        vocabulary_id
        omop_source_concept_id

    end

    icdver-->vocabulary_id
    code2_icd-->vocabulary_id

    code1_kela_disease-->fg_codes_info
    code2_icd-->fg_codes_info

    fg_codes_info-->omop_source_concept_id
```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| finngenid | finngenid | Copied as it is | Copied |
| source | source |  Copied as it is | Copied |
| approx_event_day | approx_event_day | Copied as it is | Copied |
| code1 | code1_kela_disease<br>code2_icd | Default `code1_kela_disease` will be copied.<br> For all `code2_icd` not null will be copied as well in a new row. | Split into two rows |
| code2 |  | Set NULL for all | Info not available |
| code3 | | Set NULL for all | Info not available   |
| code4 | | Set NULL for all | Info not available   |
| category | category | Copied as it is | Copied |
| index | index | Copied as it is | Copied |
| code |  |`code` from fg_codes_info where `vocabulary_id`=`vocabulary_id` and  `code1`=`fg_code1` | Calculated|
| vocabulary_id | code2_icd<br>icdver |  If `code2_icd` is NULL then `vocabulary_id` equals "REIMB"<br> If `code2_icd` is not NULL and `icdver` equals "10" then `vocabulary_id` is "ICD10fi". <br> If `code2_icd` is not NULL and `icdver` equals "9" then `vocabulary_id` is "ICD9fi". <br> If `code2_icd` is not NULL and `icdver` equals "8" then `vocabulary_id` is "ICD8fi". | Calculated |
| omop_source_concept_id | | `omop_concept_id` from fg_codes_info where `vocabulary_id`=`vocabulary_id` and `code1`=`fg_code1` | Calculated|
| default_domain |  | Default domain is "condition"| Calculated |
