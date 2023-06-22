---
title: Hilmo
layout: default
nav_order: 4
has_children: true
---

## Hilmo

Hilmo register gathers diagnoses and operations from the secondary health care centers in the country [[FinnGen Handbook](https://finngen.gitbook.io/finngen-analyst-handbook/finngen-data-specifics/red-library-data-individual-level-data/what-phenotype-files-are-available-in-sandbox-1/detailed-longitudinal-data/registers-in-the-detailed-longitudinal-data#hilmo-care-register-for-health-care)]. 

Diagnoses are coded using ICD10fi, ICD9fi, and ICD8fi vocabularies. Operations are coded using the NCSPfi, FHL, HPN, and HPN vocabularies. 

Hilmo translates to visits descending from ["Inpatient Visit"](https://athena.ohdsi.org/search-terms/terms/9201) or descending from ["Outpatient Visit"](https://athena.ohdsi.org/search-terms/terms/9202) in the `visit_occurrence` table with medical events, mostly in the `condition_occurrence` and `procedure_occurrence` table, but also in  `device_exposure`, `measurement`, `observation`. Medical events go first to the intermediary `stem` table and final table is decided based on the code's domain. 
