---
title: Vocabularies
layout: default
parent: Appendixes
nav_order: 4
---

# Appendix: Vocabularies

Vocabulary used comes from the FinOMOP vocabularies v1.0.0. 

[https://github.com/FinOMOP/FinOMOP_OMOP_vocabulary/releases/tag/v1.0.0](https://github.com/FinOMOP/FinOMOP_OMOP_vocabulary/releases/tag/v1.0.0)

This contains the vocabularies downloaded from Athena v5.0 23-JAN-23 and the vocabularies created by FinOMOP. 
Within the FinOMOP vocabularies, vocabulary `FGVisitType` was created by FinnGen to code the visit as they appear in the source data. 

### List of vocabularies from Athena

| VOCABULARY ID | VOCABULARY NAME                                                        |
|---------------|-----------------------------------------------------------------------|
| SNOMED        | Systematic Nomenclature of Medicine - Clinical Terms (IHTSDO)          |
| ICD9CM        | International Classification of Diseases, Ninth Revision, Clinical Modification, Volume 1 and 2 (NCHS) |
| ICD9Proc      | International Classification of Diseases, Ninth Revision, Clinical Modification, Volume 3 (NCHS) |
| CPT4          | Current Procedural Terminology version 4 (AMA)                         |
| HCPCS         | Healthcare Common Procedure Coding System (CMS)                        |
| LOINC         | Logical Observation Identifiers Names and Codes (Regenstrief Institute) |
| RxNorm        | RxNorm (NLM)                                                          |
| NDC           | National Drug Code (FDA and manufacturers)                             |
| Gender        | OMOP Gender                                                            |
| Race          | Race and Ethnicity Code Set (USBC)                                     |
| CMS Place of Service | Place of Service Codes for Professional Claims (CMS)             |
| ATC           | WHO Anatomic Therapeutic Chemical Classification                       |
| ICD10         | International Classification of Diseases, Tenth Revision (WHO)        |
| ICD10PCS      | ICD-10 Procedure Coding System (CMS)                                   |
| Revenue Code  | UB04/CMS1450 Revenue Codes (CMS)                                       |
| Ethnicity     | OMOP Ethnicity                                                         |
| NUCC          | National Uniform Claim Committee Health Care Provider Taxonomy Code Set (NUCC) |
| Medicare Specialty | Medicare provider/supplier specialty codes (CMS)                 |
| SPL           | Structured Product Labeling (FDA)                                      |
| OPCS4         | OPCS Classification of Interventions and Procedures version 4 (NHS)   |
| HES Specialty | Hospital Episode Statistics Specialty (NHS)                            |
| Currency      | International Currency Symbol (ISO 4217)                              |
| ABMS          | Provider Specialty (American Board of Medical Specialties)            |
| RxNorm Extension | RxNorm Extension (OHDSI)                                          |
| NAACCR        | Data Standards & Data Dictionary Volume II (NAACCR)                   |
| Nebraska Lexicon | Nebraska Lexicon                                                    |
| OMOP Extension | OMOP Extension (OHDSI)                                                |
| CAP           | CAP electronic Cancer Checklists (College of American Pathologists)   |
| CIM10         | International Classification of Diseases, Tenth Revision, French Edition |
| NCCD          | Normalized Chinese Clinical Drug                                       |
| OMOP Genomic  | OMOP Genomic vocabulary                                               |
| UCUM          | Unified Code for Units of Measure (Regenstrief Institute)              |


### List of vocabularies from FinOMOP

For more information on the mapping status see the [status dashboard](https://finngen.github.io/FinOMOP_OMOP_vocabulary/StatusReport/dashboard.html#databases-coverage)

| source_vocabulary_id | twobillionare_code | mapping_version | last_modify_date | mapping_type |
|----------------------|--------------------|-----------------|------------------|--------------|
| FHL                  | 20001              | v1.0.0          | 2022-04-22       | CCR          |
| HPN                  | 20002              | v1.0.0          | 2022-04-22       | CCR          |
| ICD8fi               | 20003              | v1.0.0          | 2022-04-22       | CCR          |
| ICD9fi               | 20004              | v1.0.0          | 2022-04-22       | CCR          |
| ICD10fi              | 20005              | v1.0.0          | 2022-04-22       | CCR          |
| LABfi                | 20006              | v1.0.0          | 2022-04-22       | CCR          |
| LABfi_TMP            | 20007              | v1.0.0          | 2022-04-22       | CCR          |
| LABfi_TKU            | 20008              | v1.0.0          | 2022-04-22       | CCR          |
| LABfi_HUS            | 20009              | v1.0.0          | 2022-04-22       | CCR          |
| MEDSPECfi            | 20010              | v1.0.0          | 2022-04-22       | CCR          |
| MICROBEfi            | 20011              | v1.0.0          | 2022-04-22       | CCR          |
| MICROBEfi_TKU        | 20012              | v1.0.0          | 2022-04-22       | CCR          |
| NCSPfi               | 20013              | v1.0.0          | 2022-04-22       | CCR          |
| SNOMED2fi            | 20014              | v1.0.0          | 2022-04-22       | CCR          |
| ProcedureModifier    | 20015              | v1.0.0          | 2022-04-22       | CCR          |
| REIMB                | 20016              | v1.0.0          | 2022-04-22       | CCR          |
| SPAT                 | 20017              | v1.0.0          | 2022-04-22       | CCR          |
| UNITfi               | 20018              | v1.0.0          | 2022-04-22       | CCR          |
| VNRfi                | 20019              | v1.0.0          | 2022-04-22       | CCR          |
| ICPC                 | 20020              | v1.0.0          | 2022-04-22       | CCR          |
| HPO                  | 20021              | v1.0.0          | 2022-04-22       | CCR          |
| ProfessionalCode     | 20022              | v1.0.0          | 2023-01-18       | CCR          |
| **FGVisitType**      | 20023              | v1.0.0          | 2023-01-18       | CCR          |
