---
title: Birth_mother
layout: default
nav_order: 9
has_children: true
---

## Birth_mother 

Birth_mother registry contains reproductive history data variables of mothers within FinnGen. Reproductive data variables come from combination of population (DVV since 1953) registry and medical birth registry (since 1987)[[FinnGen Handbook](https://finngen.gitbook.io/finngen-handbook/finngen-data-specifics/red-library-data-individual-level-data/what-phenotype-files-are-available-in-sandbox-1/other-registers/reproductive-history-data)]

Birth related diagnosis are coded using ICD10fi, ICD9fi, and ICD8fi vocabularies. One of the assumptions here is that majority of births will be in hospital and mother will spend more than a day for delivary duration.

Birth_mother translates to visits descending from ["Inpatient Hospital"](https://athena.ohdsi.org/search-terms/terms/8717) in the `visit_occurrence` table with medical events mostly in the `condition_occurrence` table. Medical events go first to the intermediary `stem` table and final table is decided based on the code's domain. 