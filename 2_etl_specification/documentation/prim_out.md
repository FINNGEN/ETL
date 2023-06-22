---
title: Prim_out
layout: default
nav_order: 5
has_children: true
---

## Prim_out

Prim_out, also know as Avohilmo, register gather diagnose and operations from primary health care centers in the country since 2011. 
[[FinnGen Handbook](https://finngen.gitbook.io/finngen-analyst-handbook/finngen-data-specifics/red-library-data-individual-level-data/what-phenotype-files-are-available-in-sandbox-1/detailed-longitudinal-data/registers-in-the-detailed-longitudinal-data#avohilmo-register-of-primary-health-care-visits)]

Diagnoses are coded using ICD10fi and ICPC2 vocabularies. Operations are coded using the ICPCproc and SPAT vocabularies. 

Prim_out translates to visits descending from descending from ["Outpatient Visit"](https://athena.ohdsi.org/search-terms/terms/9202) in the `visit_occurrence` table with medical events, mostly in the `condition_occurrence` table and `procedure_occurrence` table, but also in  `device_exposure`, `measurement`, `observation` tables. Medical events go first to the intermediary `stem` table and final table is decided based on the code's domain. 
