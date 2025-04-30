---
title: Kidney
layout: default
nav_order: 11
has_children: true
---

## Kidney 

The Finnish Registry for Kidney Diseases has comprehensive coverage of dialysis and kidney transplantation patients in Finland. FinnGen data consists of FinnGen participants with dialysis from kidney transplants in Finland since 1964. [[FinnGen Handbook](https://finngen.gitbook.io/finngen-handbook/finngen-data-specifics/red-library-data-individual-level-data/what-phenotype-files-are-available-in-sandbox-1/other-registers/finnish-registry-for-kidney-diseases)]

Kidney disease registry comes in three files related to incidence, prevalence and treamtnet. A combined file is constructed based on details about data collection and variable information from Jaakko Helve, HUS. The details of merge process can found be found within the `README` file within Sandbox. We considered all Kidney registry visits as Outpatient visits. 

Kidney translates to visits descending from ["Outpatient Visit"](https://athena.ohdsi.org/search-terms/terms/9202) in the `visit_occurrence` table. Majority of kidney registry events directed to `stem` table whereby the final table is decided on the code's domain. Columns `SYSTOLIC_BLOOD_PRESSURE`, `DIASTOLIC_BLOOD_PRESSURE`, `CHOLESTEROL`, `HDL_CHOLESTEROL` and `TRIGLYCERIDE` are directly mapped to `measurement` table. Columns `DIALYSIS_PER_WEEK`, `PRODUCTION_OF_URINE` and `PERITONITIS_PER_YEAR` are directly mapped to `observation` table.