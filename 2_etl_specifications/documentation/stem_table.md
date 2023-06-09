## Table name: stem_table

### Reading from hilmo

```mermaid
flowchart LR
    subgraph Source
        source
        code1_icd_symptom_operation_code
        code2_icd_cause_na
        code3_atc_code_na
        icdver
        category
    end

    subgraph STEM
        vocabulary_id
        omop_source_concept_id
        default_domain

    end

    source-->vocabulary_id
    icdver-->vocabulary_id
    category-->vocabulary_id
    source-->omop_source_concept_id
    code1_icd_symptom_operation_code-->omop_source_concept_id
    code2_icd_cause_na-->omop_source_concept_id
    code3_atc_code_na-->omop_source_concept_id
    source-->default_domain
    category-->default_domain
```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| finngenid |  |  | source.finngenid |
| source |  |  | source.source |
| approx_event_day |  |  | source.approx_event_day |
| code1 |  |  | source.code1_icd_symptom_operation_code |
| code2 |  |  | source.code2_icd_cause_na |
| code3 |  |  | source.code3_atc_code_na |
| code4 |  |  | source.code4_hospital_days_na |
| category |  |  | source.category |
| index |  |  | source.index |
| code |  |  | medical_codes.fg_codes_info.code |
| vocabulary_id | source<br>icdver<br>category |  | Calculated: <br> Configurable external parameters with default settings<br> ICD10fi_map_to = 'CODE1_CODE2'<br>CANC_map_to = 'MORPO_BEH_TOPO'<br>REIMB_map_to = 'REIMB'<br>REIMB1_map_to = 'ICD'<br> Given external parameters with default settings then cdm.stem.vocabulary_id is determined based on source.source, source.icdver and source.category   |
| omop_source_concept_id | source<br>code1_icd_symptom_operation_code<br>code2_icd_cause_na<br>code3_atc_code_na |  | Calculated: medical_codes.fg_codes_info.omop_source_concept_id is extracted when the following conditions are met <br> source.source = medical_codes.fg_codes_info.source AND <br> source.code1_icd_symptom_operation_code = medical_codes.fg_codes_info.fg_code1 AND <br> source.code2_icd_cause_na = medical_codes.fg_codes_info.fg_code2 AND <br> source.code3_atc_code_na = medical_codes.fg_codes_info.fg_code3  |
| default_domain | source<br>category |  | Calculated: <br> If standard code domain is NOT NULL then cdm.concept.domain_id. <br>If no standard code map available then source.source in ("OPER_IN","OPER_OUT") will have procedure as default_domain.<br> If no standard code map available then source.source is "PRIM_OUT" and source.category contains ("OP","MOP") will have procedure as default_domain.<br> If no standard code domain exists then by default the domain is condition.  |


### Reading from prim_out

```mermaid
flowchart LR
    subgraph Source
        source
        code1_code
        code2_na
        code3_na
        icdver
        category
    end

    subgraph STEM
        vocabulary_id
        omop_source_concept_id
        default_domain

    end

    source-->vocabulary_id
    icdver-->vocabulary_id
    category-->vocabulary_id
    source-->omop_source_concept_id
    code1_code-->omop_source_concept_id
    code2_na-->omop_source_concept_id
    code3_na-->omop_source_concept_id
    source-->default_domain
    category-->default_domain
```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| finngenid |  |  | source.finngenid |
| source |  |  | source.source |
| approx_event_day |  |  | source.approx_event_day |
| code1 |  |  | source.code1_code |
| code2 |  |  | source.code2_na |
| code3 |  |  | source.code3_na |
| code4 |  |  | source.code4_na |
| category |  |  | source.category |
| index |  |  | source.index |
| code |  |  | medical_codes.fg_codes_info.code |
| vocabulary_id | source<br>icdver<br>category |  | Calculated: <br> Configurable external parameters with default settings<br> ICD10fi_map_to = 'CODE1_CODE2'<br>CANC_map_to = 'MORPO_BEH_TOPO'<br>REIMB_map_to = 'REIMB'<br>REIMB1_map_to = 'ICD'<br> Given external parameters with default settings then cdm.stem.vocabulary_id is determined based on source.source, source.icdver and source.category   |
| omop_source_concept_id | source<br>code1_code<br>code2_na<br>code3_na |  | Calculated: medical_codes.fg_codes_info.omop_source_concept_id is extracted when the following conditions are met <br> source.source = medical_codes.fg_codes_info.source AND <br> source.code1_code = medical_codes.fg_codes_info.fg_code1 AND <br> source.code2_na = medical_codes.fg_codes_info.fg_code2 AND <br> source.code3_na = medical_codes.fg_codes_info.fg_code3  |
| default_domain | source<br>category |  | Calculated: <br> If standard code domain is NOT NULL then cdm.concept.domain_id. <br>If no standard code map available then source.source in ("OPER_IN","OPER_OUT") will have procedure as default_domain.<br> If no standard code map available then source.source is "PRIM_OUT" and source.category contains ("OP","MOP") will have procedure as default_domain.<br> If no standard code domain exists then by default the domain is condition.  |

### Reading from reimb

```mermaid
flowchart LR
    subgraph Source
        source
        code1_kela_disease
        code2_icd
        code3_na
        icdver
        category
    end

    subgraph STEM
        vocabulary_id
        omop_source_concept_id
        default_domain

    end

    source-->vocabulary_id
    icdver-->vocabulary_id
    category-->vocabulary_id
    source-->omop_source_concept_id
    code1_kela_disease-->omop_source_concept_id
    code2_icd-->omop_source_concept_id
    code3_na-->omop_source_concept_id
    source-->default_domain
    category-->default_domain
```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| finngenid |  |  | source.finngenid |
| source |  |  | source.source |
| approx_event_day |  |  | source.approx_event_day |
| code1 |  |  | source.code1_kela_disease |
| code2 |  |  | source.code2_icd |
| code3 |  |  | source.code3_na |
| code4 |  |  | source.code4_na |
| category |  |  | source.category |
| index |  |  | source.index |
| code |  |  | medical_codes.fg_codes_info.code |
| vocabulary_id | source<br>icdver<br>category |  | Calculated: <br> Configurable external parameters with default settings<br> ICD10fi_map_to = 'CODE1_CODE2'<br>CANC_map_to = 'MORPO_BEH_TOPO'<br>REIMB_map_to = 'REIMB'<br>REIMB1_map_to = 'ICD'<br> Given external parameters with default settings then cdm.stem.vocabulary_id is determined based on source.source, source.icdver and source.category   |
| omop_source_concept_id | source<br>code1_kela_disease<br>code2_icd<br>code3_na |  | Calculated: medical_codes.fg_codes_info.omop_source_concept_id is extracted when the following conditions are met <br> source.source = medical_codes.fg_codes_info.source AND <br> source.code1_kela_disease = medical_codes.fg_codes_info.fg_code1 AND <br> source.code2_icd = medical_codes.fg_codes_info.fg_code2 AND <br> source.code3_na = medical_codes.fg_codes_info.fg_code3  |
| default_domain | source<br>category |  | Calculated: <br> If standard code domain is NOT NULL then cdm.concept.domain_id. <br>If no standard code map available then source.source in ("OPER_IN","OPER_OUT") will have procedure as default_domain.<br> If no standard code map available then source.source is "PRIM_OUT" and source.category contains ("OP","MOP") will have procedure as default_domain.<br> If no standard code domain exists then by default the domain is condition.  |

### Reading from canc

```mermaid
flowchart LR
    subgraph Source
        source
        code1_topo
        code2_morpho
        code3_beh
        icdver
        category
    end

    subgraph STEM
        vocabulary_id
        omop_source_concept_id
        default_domain

    end

    source-->vocabulary_id
    icdver-->vocabulary_id
    category-->vocabulary_id
    source-->omop_source_concept_id
    code1_topo-->omop_source_concept_id
    code2_morpho-->omop_source_concept_id
    code3_beh-->omop_source_concept_id
    source-->default_domain
    category-->default_domain
```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| finngenid |  |  | source.finngenid |
| source |  |  | source.source |
| approx_event_day |  |  | source.approx_event_day |
| code1 |  |  | source.code1_topo |
| code2 |  |  | source.code2_morpho |
| code3 |  |  | source.code3_beh |
| code4 |  |  | source.code4_na |
| category |  |  | source.category |
| index |  |  | source.index |
| code |  |  | medical_codes.fg_codes_info.code |
| vocabulary_id | source<br>icdver<br>category |  | Calculated: <br> Configurable external parameters with default settings<br> ICD10fi_map_to = 'CODE1_CODE2'<br>CANC_map_to = 'MORPO_BEH_TOPO'<br>REIMB_map_to = 'REIMB'<br>REIMB1_map_to = 'ICD'<br> Given external parameters with default settings then cdm.stem.vocabulary_id is determined based on source.source, source.icdver and source.category   |
| omop_source_concept_id | source<br>code1_topo<br>code2_morpho<br>code3_beh |  | Calculated: medical_codes.fg_codes_info.omop_source_concept_id is extracted when the following conditions are met <br> source.source = medical_codes.fg_codes_info.source AND <br> source.code1_topo = medical_codes.fg_codes_info.fg_code1 AND <br> source.code2_morpho = medical_codes.fg_codes_info.fg_code2 AND <br> source.code3_beh = medical_codes.fg_codes_info.fg_code3  |
| default_domain | source<br>category |  | Calculated: <br> If standard code domain is NOT NULL then cdm.concept.domain_id. <br>If no standard code map available then source.source in ("OPER_IN","OPER_OUT") will have procedure as default_domain.<br> If no standard code map available then source.source is "PRIM_OUT" and source.category contains ("OP","MOP") will have procedure as default_domain.<br> If no standard code domain exists then by default the domain is condition.  |

### Reading from death_register

```mermaid
flowchart LR
    subgraph Source
        source
        code1_cause_of_death
        code2_na
        code3_na
        icdver
        category
    end

    subgraph STEM
        vocabulary_id
        omop_source_concept_id
        default_domain

    end

    source-->vocabulary_id
    icdver-->vocabulary_id
    category-->vocabulary_id
    source-->omop_source_concept_id
    code1_cause_of_death-->omop_source_concept_id
    code2_na-->omop_source_concept_id
    code3_na-->omop_source_concept_id
    source-->default_domain
    category-->default_domain
```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| finngenid |  |  | source.finngenid |
| source |  |  | source.source |
| approx_event_day |  |  | source.approx_event_day |
| code1 |  |  | source.code1_cause_of_death |
| code2 |  |  | source.code2_na |
| code3 |  |  | source.code3_na |
| code4 |  |  | source.code4_na |
| category |  |  | source.category |
| index |  |  | source.index |
| code |  |  | medical_codes.fg_codes_info.code |
| vocabulary_id | source<br>icdver<br>category |  | Calculated: <br> Configurable external parameters with default settings<br> ICD10fi_map_to = 'CODE1_CODE2'<br>CANC_map_to = 'MORPO_BEH_TOPO'<br>REIMB_map_to = 'REIMB'<br>REIMB1_map_to = 'ICD'<br> Given external parameters with default settings then cdm.stem.vocabulary_id is determined based on source.source, source.icdver and source.category   |
| omop_source_concept_id | source<br>code1_cause_of_death<br>code2_na<br>code3_na |  | Calculated: medical_codes.fg_codes_info.omop_source_concept_id is extracted when the following conditions are met <br> source.source = medical_codes.fg_codes_info.source AND <br> source.code1_cause_of_death = medical_codes.fg_codes_info.fg_code1 AND <br> source.code2_na = medical_codes.fg_codes_info.fg_code2 AND <br> source.code3_na = medical_codes.fg_codes_info.fg_code3  |
| default_domain | source<br>category |  | Calculated: <br> If standard code domain is NOT NULL then cdm.concept.domain_id. <br>If no standard code map available then source.source in ("OPER_IN","OPER_OUT") will have procedure as default_domain.<br> If no standard code map available then source.source is "PRIM_OUT" and source.category contains ("OP","MOP") will have procedure as default_domain.<br> If no standard code domain exists then by default the domain is condition.  |