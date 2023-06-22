---
title: Purch
layout: default
nav_order: 3
has_children: true
---

# Purch

Kela drug purchase registry (PURCH) contains the drug purchase at a pharmacy starting from 1995 [[FinnGen Handbook](https://finngen.gitbook.io/finngen-analyst-handbook/finngen-data-specifics/red-library-data-individual-level-data/what-phenotype-files-are-available-in-sandbox-1/detailed-longitudinal-data/registers-in-the-detailed-longitudinal-data#the-care-notification-system-hilmo)].

Drugs are coded using the VNR vocabulary. 

Purch translates to ["Pharmacy visit"](https://athena.ohdsi.org/search-terms/terms/581458) in the `visit_occurrence` table with one or more events in the `drug_exposure` table.




