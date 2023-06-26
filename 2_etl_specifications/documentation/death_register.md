---
title: Death_register
layout: default
nav_order: 8
has_children: true
---


## Death_register

Death register gathers the death certificates since 1969. [[FinnGen Handbook](https://finngen.gitbook.io/finngen-analyst-handbook/finngen-data-specifics/red-library-data-individual-level-data/what-phenotype-files-are-available-in-sandbox-1/detailed-longitudinal-data/registers-in-the-detailed-longitudinal-data#cause-of-death-data-statistics-finland)]. 

Caused of death are coded using ICD10fi, ICD9fi, and ICD8fi vocabularies. 

The death table in the CDM allows for only one cause of death per person. The rest of the causes of death are stored under no related visit, mostly in the `condition_occurrence`, but also in the `procedure_occurrence`,  `device_exposure`, `measurement`, `observation`. Medical events go first to the intermediary `stem` table and final table is decided based on the code's domain. 
