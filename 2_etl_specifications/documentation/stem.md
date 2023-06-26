---
title: Stem
layout: default
nav_order: 9
has_children: true
---

## Stem

Stem table is an intermediary table used to simplified the ETL. 
The target domain for the medical codes in the source tables is not know until they are mapped to the standard codes. 
The stem table creates an entry for each of the medical events in the source tables. 
It maps all the source medical codes to the corresponding source_concept_id using the `fg_codes_table` mapping table and calculates the default domain.
If the source medical code has an source_concept_id, the default domain is obtained from the `concept` table, other wise it is set to "condition" or "procedure" depending on the source table. 
