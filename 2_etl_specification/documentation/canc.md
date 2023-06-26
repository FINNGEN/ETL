---
title: Canc
layout: default
nav_order: 7
has_children: true
---


## Canc

Cancer register gathers curated cancer diagnosed from centers in the country since 1953 [[FinnGen Handbook](https://finngen.gitbook.io/finngen-analyst-handbook/finngen-data-specifics/red-library-data-individual-level-data/what-phenotype-files-are-available-in-sandbox-1/detailed-longitudinal-data/registers-in-the-detailed-longitudinal-data#finnish-cancer-registry)]. 

Diagnoses are coded using ICDO3 vocabularies. 

Canc translates to ["Ambulatory Oncology Clinic / Center"](https://athena.ohdsi.org/search-terms/terms/38004268) in the `visit_occurrence` table with medical events, mostly in the `condition_occurrence`, but also in the `procedure_occurrence`,  `device_exposure`, `measurement`, `observation`. Medical events go first to the intermediary `stem` table and final table is decided based on the code's domain. 
