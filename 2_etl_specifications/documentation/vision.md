---
title: Vision
layout: default
nav_order: 10
has_children: true
---

## Vision 

Visual impairment registry contains diagnosis related to visual impairment and measurements from both eyes within FinnGen. FinnGen visual impairment registry data includes population distribution and epidemiology of visual impairments (since 1983)[[FinnGen Handbook](https://finngen.gitbook.io/finngen-handbook/finngen-data-specifics/red-library-data-individual-level-data/what-phenotype-files-are-available-in-sandbox-1/other-registers/the-finnish-register-of-visual-impairment)]

Visual impairment related diagnosis are coded using majorly using ICD9CM vocabulary and two codes from ICD10 vocabulary. One of the assumptions here is that majority of visits to Ophthalmologist/Optometrist for vision check will be done at care site and will take less than a day.

Vision translates to visits descending from ["Outpatient Visit"](https://athena.ohdsi.org/search-terms/terms/9202) in the `visit_occurrence` table. Majority of vision diagnosis events go directly into the `condition_occurrence` table with only a few being directed to `stem` table whereby the final table is decided on the code's domain. Visual field diameter values are directly mapped to `measurement` table.