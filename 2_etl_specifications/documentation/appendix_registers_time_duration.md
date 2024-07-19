---
title: Registers time duration
layout: default
parent: Appendixes
nav_order: 3
---

# Appendix: Registers time duration

Following plot shows the start and end of each source register and the vocabularies used during these periods. 

Hilmo register has been broken in to 4 parts corresponding to the internal labels of the register. 

```mermaid 
---
displayMode: compact
---
gantt
    title Register Time Durations
    dateFormat YYYY
    axisFormat %Y

    section PRIM_OUT
    ICD10fi+SPAT+ICPC+NCSPfi(dental)       : 2011, 2023

    section HILMO-OPER_OUT
    NCSPfi+FHL+HPO+HPN         : 1998, 2023

    section HILMO-OUTPAT
    ICD10fi         : 1998, 2023

    section PURCH
    VNRfi         : 1998, 2023

    section HILMO-OPER_IN
    NCSPfi+FHL+HPO+HPN         : 1969, 2023

    section HILMO-INPAT
    ICD8fi         : 1969, 1988
    ICD9fi         : 1988, 1998
    ICD10fi        : 1998, 2023

    section DEATH
    ICD8fi         : 1969, 1988
    ICD9fi         : 1988, 1998
    ICD10fi        : 1998, 2023

    section REIMB
    REIMB         : 1969, 1988
    REIMB+ICD9fi   : 1988, 1998
    REIMB+ICD10fi  : 1998, 2023

    section CANC
    ICDO3            : 1953, 2023
    
    section BIRTH_MOTHER
    ICD9fi           : 1986, 2012
    ICD10+ICD10fi            : 1986, 2023
    
    section VISION
    ICD9CM            : 1926, 2021
    ICD10           : 2006, 2006
```
