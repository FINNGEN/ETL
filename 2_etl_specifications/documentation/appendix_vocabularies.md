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

| VOCABULARY ID | VOCABULARY NAME            |
|----------------------|--------------------|
| FHL                  | Finnish Hospital League              |
| ICD8fi               | International Classification of Diseases, Eight Revision (Finland)                | 
| HPN                  | Heart Patients Codes (New)             |
| ICD9fi               | International Classification of Diseases, Ninth Revision (Finland)              | 
| ICD10fi              | International Classification of Diseases, Tenth Revision (Finland)                | 
| LABfi                | Laboratory Codes Finland             | 
| LABfi_TMP            | Laboratory Codes Finland, Tampere Hospital Extension              | 
| LABfi_TKU            | Laboratory Codes Finland, Turku Hospital Extension              | 
| LABfi_HUS            | Laboratory Codes Finland, Helsinki Hospital Extension              | 
| MEDSPECfi            | Medical Specialty Finland              | 
| MICROBEfi            | Microbial Codes Finland               | 
| MICROBEfi_TKU        | Microbial Codes Finland, Turku Hospital Extension                 | 
| NCSPfi               | NOMESCO Classification of Surgical Procedures (Finland)              | 
| SNOMED2fi            | Systematic Nomenclature of Medicine 2  (Finland)              | 
| ProcedureModifier    | Procedure Modifier              | 
| REIMB                | Kela Reimbursement Codes              | 
| SPAT                 | SPAT Procedure Codes For Primary Care              | 
| UNITfi               | Units Finland              | 
| VNRfi                | Nordic Article Number   (Finland)            | 
| ICPC                 | International Classification of Primary Care              | 
| HPO                  | Heart Patients Codes (Old)                     | 
| ProfessionalCode     | Professional Code              | 
| **FGVisitType**      | FinnGen Visit Type              | 
