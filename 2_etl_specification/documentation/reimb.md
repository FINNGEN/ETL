---
title: Reimb
layout: default
nav_order: 6
has_children: true
---


## Reimb

Reimbursement register gathers diagnoses indicating the reason why a patient was entitled for reimbursement of certain drugs [[FinnGen Handbook](https://finngen.gitbook.io/finngen-analyst-handbook/finngen-data-specifics/red-library-data-individual-level-data/what-phenotype-files-are-available-in-sandbox-1/detailed-longitudinal-data/registers-in-the-detailed-longitudinal-data#drug-reimbursement-data-the-social-insurance-institution-kela-kansanelaekelaitos)]. 

Diagnoses are coded using ICD10fi, ICD9fi, and REIMB vocabularies. 

Reimb translates ["Case Management Visit"](https://athena.ohdsi.org/search-terms/terms/38004193) in the `visit_occurrence` table with medical events, mostly in the `condition_occurrence` table, but also in `procedure_occurrence`,  `device_exposure`, `measurement`, `observation` tables. Medical events go first to the intermediary `stem` table and final table is decided based on the code's domain. 
