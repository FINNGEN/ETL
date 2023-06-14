# Source Data Mapping Approach to CDMV5.4

```mermaid
flowchart LR
    subgraph Register Tables
        finngenid_info
        purch
        hilmo
        prim_out
        reimb
        canc
        death_register
    end

    subgraph CDM-OMOP-v5.4
        person
        observation_period
        visit_occurrence
        drug_exposure
        conndition_occurrence
        procedure_occurrence
        device_exposure
        measurement
        observation
        death
        provider
    end


    finngenid_info-->person
    finngenid_info-->observation_period

    purch --> visit_occurrence
    purch --> drug_exposure

    hilmo --> visit_occurrence
    hilmo --> stem

    prim_out --> visit_occurrence
    prim_out --> stem

    reimb --> visit_occurrence
    reimb --> stem

    canc --> visit_occurrence
    canc --> stem

    death_register --> visit_occurrence
    death_register --> stem

    stem --> conndition_occurrence 
    stem --> procedure_occurrence
    stem --> device_exposure
    stem --> observation
    stem --> measurement
    stem --> death

    fg_codes_info --> stem 
    fg_codes_info --> visit_occurrence 
    fg_codes_info-->provider
    
```

## Contents

[person](person.md)

[observation_period](observation_period.md)

[visit_occurrence](visit_occurrence.md)

[drug_exposure](drug_exposure.md)

[stem_table](stem_table.md)

[condition_occurrence](condition_occurrence.md)

[procedure_occurrence](procedure_occurrence.md)

[device_exposure](device_exposure.md)

[measurement](measurement.md)

[observation](observation.md)

[death](death.md)

[provider](provider.md)

[source_appendix](source_appendix.md)

