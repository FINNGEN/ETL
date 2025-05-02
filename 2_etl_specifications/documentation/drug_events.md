---
title: Drug_events
layout: default
nav_order: 3
has_children: true
---

# Drug Events

Drug Events table is a combination of events from three registeries. 

Kela drug purchase registry (PURCH) contains the drug purchase at a pharmacy starting from 1995 [[FinnGen Handbook](https://finngen.gitbook.io/finngen-analyst-handbook/finngen-data-specifics/red-library-data-individual-level-data/what-phenotype-files-are-available-in-sandbox-1/detailed-longitudinal-data/registers-in-the-detailed-longitudinal-data#the-care-notification-system-hilmo)].

Kanta Prescription (PRESCRIPTION) contains the drug prescriptions issued starting from 2010 [[FinnGen Handbook](http://docs.finngen.fi/finngen-data-specifics/red-library-data-individual-level-data/what-phenotype-files-are-available-in-sandbox-1/kanta-prescriptions)]. Important to note is that these are prescriptions that were issued but does not necessarily mean they were delivered but some similar drug could be delivered.

Kanta Medication Delivery (MEDICATION_DELIVERY) contains drugs that were delivered based on the Kanta prescription starting from 2010. 

Drugs are coded using the VNR vocabulary. 

Purch translates to ["Pharmacy visit"](https://athena.ohdsi.org/search-terms/terms/581458) in the `visit_occurrence` table with one or more events in the `drug_exposure` table.




