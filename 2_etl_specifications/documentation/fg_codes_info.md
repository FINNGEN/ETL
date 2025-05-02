---
title: Fg_codes_info
layout: default
nav_order: 13
has_children: true
---

## Fg_codes_info

Medical and visit codes in the source tables have been split and some have been merged together into differten columns.
To ease the code mapping, rather than reshape the large provided tables we use a mapping table `fg_codes_info`. 
The `fg_codes_info` contains the the source code as expressed in the source tables (columns `fg_code_x`) and the equivalent `omop_source_concept_id`. 
