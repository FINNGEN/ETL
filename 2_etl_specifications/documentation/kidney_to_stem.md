---
title: kidney to stem
layout: default
parent: Kidney
nav_order: 2
---

## kidney to stem

```mermaid
%%{init: {'theme': 'base' } }%%
%%{init: {'theme': 'base' } }%%
flowchart LR
    subgraph Source
        kidney_disease_diagnosis_1
        kidney_disease_diagnosis_2
        angina_pectoris
        heart_attack
        other_vascular_disease
        stroke
        t1d
        t2d
        unknown_type_of_diabetes
        bypass_or_other_procedure
        left_ventricular_hypertrophy
        heart_failure
        other_vascular_disease_entry
        other_vascular_disease_amputation
        dyslipidemia_diet_treatment
        dyslipidemia_medical_treatment
        fistula_in_first_dialysis_treatment
        antihypertensive_drug
        iv_iron
        other_immunosuppressive
        current_form_of_treatment
        smoking_previous
        smoking_current
        rr_medical_treatment
        vitamin_d_treatment
        epo_treatment
        fistula
        esa_treatment
    end

    fg_codes_info[[fg_codes_info]]

    subgraph STEM
        omop_source_concept_id

    end

    kidney_disease_diagnosis_1-->fg_codes_info
	kidney_disease_diagnosis_2-->fg_codes_info
	angina_pectoris-->fg_codes_info
	heart_attack-->fg_codes_info
	other_vascular_disease-->fg_codes_info
	stroke-->fg_codes_info
	t1d-->fg_codes_info
	t2d-->fg_codes_info
	unknown_type_of_diabetes-->fg_codes_info
	bypass_or_other_procedure-->fg_codes_info
	left_ventricular_hypertrophy-->fg_codes_info
	heart_failure-->fg_codes_info
	other_vascular_disease_entry-->fg_codes_info
	other_vascular_disease_amputation-->fg_codes_info
	dyslipidemia_diet_treatment-->fg_codes_info
	dyslipidemia_medical_treatment-->fg_codes_info
	fistula_in_first_dialysis_treatment-->fg_codes_info
	antihypertensive_drug-->fg_codes_info
	iv_iron-->fg_codes_info
	other_immunosuppressive-->fg_codes_info
	current_form_of_treatment-->fg_codes_info
	smoking_previous-->fg_codes_info
	smoking_current-->fg_codes_info
	rr_medical_treatment-->fg_codes_info
	vitamin_d_treatment-->fg_codes_info
	epo_treatment-->fg_codes_info
	fistula-->fg_codes_info
	esa_treatment-->fg_codes_info

    fg_codes_info-->omop_source_concept_id
```

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| finngenid | finngenid | Copied as it is | Copied |
| source |  |  "KIDNEY" for kidney_disease_diagnosis_1<br>kidney_disease_diagnosis_2<br> ELSE column name is the `source`  | Calculated |
| approx_event_day | | Directly taken from `approx_event_day` when not NULL <br> when NULL then end date of the `year` will be used. Ex: If `year` is 2019 then 2019-12-31 will be the `approx_event_day` | Calculated |
| code1 | kidney_disease_diagnosis_1<br>kidney_disease_diagnosis_2<br>angina_pectoris<br>heart_attack<br>other_vascular_disease<br>stroke<br>t1d<br>t2d<br>unknown_type_of_diabetes<br>bypass_or_other_procedure<br>left_ventricular_hypertrophy<br>heart_failure<br>other_vascular_disease_entry<br>other_vascular_disease_amputation<br>dyslipidemia_diet_treatment<br>dyslipidemia_medical_treatment<br>fistula_in_first_dialysis_treatment<br>antihypertensive_drug<br>iv_iron<br>other_immunosuppressive<br>current_form_of_treatment<br>smoking_previous<br>smoking_current<br>rr_medical_treatment<br>vitamin_d_treatment<br>epo_treatment<br>fistula<br>esa_treatment | For `kidney_disease_diagnosis_1` and `kidney_disease_diagnosis_2` there are combination codes and the first part is copied into `code1` after splitting by "*"  | Copied <br> NOTE: `kidney` table is a wide format (one column per diagnose). It is transformed to long format when converted to the `stem` table (one row per not null diagnose)   |
| code2 | kidney_disease_diagnosis_1<br>kidney_disease_diagnosis_2 | The second component of split by "*" is copied to `code2` | Copied |
| code3 | | Set NULL for all | Info not available   |
| code4 | | Set NULL for all | Info not available   |
| category |  | Set NULL for all | Info not available |
| index |  | Empty string | Calculated |
| code |  |`code` from fg_codes_info  | Calculated|
| vocabulary_id |  |  If `code1` starts with 0-9 then `vocabulary_id` is "ICD9fi".<br> ELSE `vocabulary_id` is "ICD10fi". | Calculated |
| omop_source_concept_id | | For `source` = "KIDNEY":<br> `omop_concept_id` from fg_codes_info where<br> `SOURCE`=`SOURCE` and <br>`code1`=`fg_code1` and<br> `code2`=`fg_code2` and<br> `code3`=`fg_code3`<br>For rest:<br>`omop_concept_id` from fg_codes_info where<br> `vocabulary_id`=`vocabulary_id` and <br>`code1`=`fg_code1` and<br> `code2`=`fg_code2` and<br> `code3`=`fg_code3` | Calculated |
| default_domain |  | Default domain is "condition" | Calculated |
