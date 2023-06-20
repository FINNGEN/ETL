# Appendix: source tables

### Table: finngenid_info

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| finngenid | STRING |  |  |
| bl_year | INT64 | 2019 |  |
| bl_age | FLOAT64 |  |  |
| sex | STRING | female |  |
| height | INT64 |  |  |
| height_age | FLOAT64 |  |  |
| weight | INT64 |  |  |
| weight_age | FLOAT64 |  |  |
| smoke2 | STRING | no |  |
| smoke3 | STRING |  |  |
| smoke5 | STRING |  |  |
| smoke_age | FLOAT64 |  |  |
| regionofbirth | INT64 | 1 |  |
| regionofbirthname | STRING | Uusimaa |  |
| movedabroad | INT64 |  |  |
| number_of_offspring | INT64 | 2 |  |
| approx_birth_date | DATE |  |  |
| fu_end_age | FLOAT64 |  |  |

### Table: purch

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| finngenid | STRING |  |  |
| source | STRING | PURCH |  |
| event_age | FLOAT64 |  |  |
| approx_event_day | DATE |  |  |
| code1_atc_code | STRING | C07AB07 |  |
| code2_sair | STRING |  |  |
| code3_vnro | STRING | 193102 |  |
| code4_plkm | STRING | 1 |  |
| code5_reimbursement | STRING | 0 |  |
| code6_additional_reimbursement | STRING | 0 |  |
| code7_reimbursement_category | STRING | O |  |
| icdver | STRING |  |  |
| category | STRING |  |  |
| index | STRING |  |  |

### Table: hilmo

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| finngenid | STRING |  |  |
| source | STRING | OUTPAT |  |
| event_age | FLOAT64 | 71.68 |  |
| approx_event_day | DATE | 2021-11-12 |  |
| code1_icd_symptom_operation_code | STRING | I10 |  |
| code2_icd_cause_na | STRING |  |  |
| code3_atc_code_na | STRING |  |  |
| code4_hospital_days_na | STRING |  |  |
| code5_service_sector | STRING | 93 |  |
| code6_speciality | STRING | 70 |  |
| code7_hospital_type | STRING | University Hospital |  |
| code8_contact_type | STRING |  |  |
| code9_urgency | STRING |  |  |
| icdver | STRING | 10 |  |
| category | STRING | 0 |  |
| index | STRING |  |  |

### Table: prim_out

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| finngenid | STRING |  |  |
| source | STRING | PRIM_OUT |  |
| event_age | FLOAT64 |  |  |
| approx_event_day | DATE | 2021-03-02 |  |
| code1_code | STRING | A98 |  |
| code2_na | STRING |  |  |
| code3_na | STRING |  |  |
| code4_na | STRING |  |  |
| code5_contact_type | STRING | R10 |  |
| code6_service_sector | STRING | T40 |  |
| code7_professional_code | STRING | 51321 |  |
| icdver | STRING | 10 |  |
| category | STRING | ICP0 |  |
| index | STRING |  |  |

### Table: reimb

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| finngenid | STRING |  |  |
| source | STRING | REIMB |  |
| event_age | FLOAT64 |  |  |
| approx_event_day | DATE | 2016-12-15 |  |
| code1_kela_disease | STRING | 205 |  |
| code2_icd | STRING | E11 |  |
| code3_na | STRING |  |  |
| code4_na | STRING |  |  |
| icdver | STRING | 10 |  |
| category | STRING |  |  |
| index | STRING |  |  |

### Table: canc

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| finngenid | STRING |  |  |
| source | STRING | CANC |  |
| event_age | FLOAT64 | 68.14 |  |
| approx_event_day | DATE | 2018-11-01 |  |
| code1_topo | STRING | C619 |  |
| code2_morpho | STRING | 8140 |  |
| code3_beh | STRING | 3 |  |
| code4_na | STRING |  |  |
| icdver | STRING | O3 |  |
| category | STRING |  |  |
| index | STRING |  |  |

### Table: death_register

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| finngenid | STRING |  |  |
| source | STRING | DEATH |  |
| event_age | FLOAT64 | 83.78 |  |
| approx_event_day | DATE | 2019-12-03 |  |
| code1_cause_of_death | STRING | I251 |  |
| code2_na | STRING |  |  |
| code3_na | STRING |  |  |
| code4_na | STRING |  |  |
| icdver | STRING | 10 |  |
| category | STRING | U |  |
| index | STRING |  |  |

### Table: stem_table

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| finngenid | STRING |  |  |
| source | STRING |  |  |
| approx_event_day | DATE |  |  |
| code1 | STRING |  |  |
| code2 | STRING |  |  |
| code3 | STRING |  |  |
| code4 | STRING |  |  |
| category | STRING |  |  |
| index | STRING |  |  |
| code | STRING |  |  |
| vocabulary_id | STRING |  |  |
| omop_source_concept_id | STRING |  |  |
| default_domain | STRING |  |  |

### Table: fg_codes_info

| Field | Type | Most freq. value | Comment |
| --- | --- | --- | --- |
| fg_code1 | STRING |  |  |
| fg_code2 | STRING |  |  |
| fg_code3 | STRING |  |  |
| source | STRING |  |  |
| fg_code5 | STRING |  |  |
| fg_code6 | STRING |  |  |
| fg_code7 | STRING |  |  |
| fg_code8 | STRING |  |  |
| fg_code9 | STRING |  |  |
| code | STRING |  |  |
| vocabulary_id | STRING |  |  |
| concept_class_id | STRING |  |  |
| name_en | STRING |  |  |
| name_fi | STRING |  |  |
| omop_source_concept_id | STRING |  |  |
