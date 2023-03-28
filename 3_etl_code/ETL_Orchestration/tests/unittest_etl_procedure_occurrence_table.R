# DESCRIPTION:
# Unit tests for etl_procedure_occurrence.
#
# PARAMETERS:
#
# Test ids: 06xx
# Finngenids: FG0060xxyyy

# Declare Test - 0601 - Default
declareTest(0601, "etl_procedure_occurrence works with defaults")

add_finngenid_info(
  finngenid="FG0601001"
)
add_hilmo(
  finngenid = "FG0601001",
  source = "OPER_IN",
  event_age = as_subquery(47.42),
  approx_event_day = "1994-03-08",
  code1_icd_symptom_operation_code = "CKD40",
  code6_speciality = "10",
  category = "NOM3",
  index = "FG0601001-1")
expect_procedure_occurrence(
  #procedure_occurrence_id is rand
  person_id = lookup_person("person_id", person_source_value="FG0601001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0601001"),
                                                visit_source_value = "SOURCE=OPER_IN;INDEX=FG0601001-1"),
  procedure_concept_id = as_subquery(4334592),
  procedure_date = "1994-03-08",
  procedure_datetime = "1994-03-08T00:00:00",
  procedure_end_date = "1994-03-08",
  procedure_end_datetime = "1994-03-08T00:00:00",
  procedure_type_concept_id = as_subquery(32879),
  modifier_concept_id = as_subquery(0),
  quantity = as_subquery(1),
  provider_id = lookup_provider("provider_id", specialty_source_concept_id = as_subquery(2001000101)),
  visit_detail_id = NULL,
  procedure_source_value = "CKD40",
  procedure_source_concept_id = as_subquery(2001301413),
  modifier_source_value = NULL
)

# TESTS MAPPING CODES WITH STANDARD MAPPING  -----------------------------------------------------------------------------

# Declare Test - 0602 - Find standard for an example code in each source in HILMO and PRIM_OUT
declareTest(0602, "etl_procedure_occurrence adds one event for each code with standard mapping for sources in HILMO and PRIM_OUT registries")

add_finngenid_info(
  finngenid="FG0602001"
)
# INPAT
add_hilmo(
  finngenid = "FG0602001",
  source = "INPAT",
  code1_icd_symptom_operation_code = "Z466",
  code2_icd_cause_na = NULL,
  icdver = "10",
  category = "1",
  index = "FG0602001-1"
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0602001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0602001"),
                                                visit_source_value = "SOURCE=INPAT;INDEX=FG0602001-1"),
  procedure_concept_id = as_subquery(4047347),
  procedure_source_value = "Z466",
  procedure_source_concept_id = as_subquery(45542434)
)

# OPER_IN
add_hilmo(
  finngenid = "FG0602001",
  source = "OPER_IN",
  code1_icd_symptom_operation_code = "CKD40",
  code2_icd_cause_na = NULL,
  category = "NOM6",
  index = "FG0602001-1"
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0602001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0602001"),
                                                visit_source_value = "SOURCE=OPER_IN;INDEX=FG0602001-1"),
  procedure_concept_id = as_subquery(4334592),
  procedure_source_value = "CKD40",
  procedure_source_concept_id = as_subquery(2001301413)
)

# OPER_OUT
add_hilmo(
  finngenid = "FG0602001",
  source = "OPER_OUT",
  code1_icd_symptom_operation_code = "SJC50",
  code2_icd_cause_na = NULL,
  category = "NOM4",
  index = "FG0602001-1"
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0602001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0602001"),
                                                visit_source_value = "SOURCE=OPER_OUT;INDEX=FG0602001-1"),
  procedure_concept_id = as_subquery(4125336),
  procedure_source_value = "SJC50",
  procedure_source_concept_id = as_subquery(2001310435)
)

# OUTPAT
add_hilmo(
  finngenid = "FG0602001",
  source = "OUTPAT",
  code1_icd_symptom_operation_code = "Z516",
  code2_icd_cause_na = NULL,
  icdver = "10",
  category = "1",
  index = "FG0602001-1"
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0602001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0602001"),
                                                visit_source_value = "SOURCE=OUTPAT;INDEX=FG0602001-1"),
  procedure_concept_id = as_subquery(4057262),
  procedure_source_value = "Z516",
  procedure_source_concept_id = as_subquery(45605134)
)

# PRIM_OUT
add_prim_out(
  finngenid = "FG0602001",
  source = "PRIM_OUT",
  code1_code = "AA1BG",
  icdver = NULL,
  category = "MOP1",
  index = "FG0602001-1"
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0602001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0602001"),
                                                visit_source_value = "SOURCE=PRIM_OUT;INDEX=FG0602001-1"),
  procedure_concept_id = as_subquery(4082979),
  procedure_source_value = "AA1BG",
  procedure_source_concept_id = as_subquery(2001300112)
)

# TESTS MAPPING CODES WITH MULTIPLE STANDARD MAPPING  -----------------------------------------------------------------------------

# Declare Test - 0603 - ICD10 code that maps to two standard codes - one condition and one procedure but only outputs procedure
declareTest(0603, "etl_procedure_occurrence adds only one event for a code with standard mapping to 2 codes one condition and one procedure")

add_finngenid_info(
  finngenid="FG0603001"
)
add_hilmo(
  finngenid = "FG0603001",
  source = "INPAT",
  code1_icd_symptom_operation_code = "F1023",
  icdver = "10",
  index = "FG0603001-1"
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0603001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0603001"),
                                                visit_source_value = "SOURCE=INPAT;INDEX=FG0603001-1"),
  procedure_concept_id = as_subquery(4079501),
  procedure_source_value = "F1023",
  procedure_source_concept_id = as_subquery(2000501680)
)

# Declare Test - 0604 - NCSP code that maps to two standard codes both procedure codes
declareTest(0604, "etl_procedure_occurrence adds two events for a code with standard mapping to two codes both procedure")

add_finngenid_info(
  finngenid="FG0604001"
)
add_hilmo(
  finngenid = "FG0604001",
  source = "OPER_OUT",
  code1_icd_symptom_operation_code = "SJD00",
  category = "NOM2",
  index = "FG0604001-1"
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0604001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0604001"),
                                                visit_source_value = "SOURCE=OPER_OUT;INDEX=FG0604001-1"),
  procedure_concept_id = as_subquery(4122493),
  procedure_source_value = "SJD00",
  procedure_source_concept_id = as_subquery(2001310437)
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0604001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0604001"),
                                                visit_source_value = "SOURCE=OPER_OUT;INDEX=FG0604001-1"),
  procedure_concept_id = as_subquery(4126618),
  procedure_source_value = "SJD00",
  procedure_source_concept_id = as_subquery(2001310437)
)

# TESTS CODES WITH NON-STANDARD MAPPING BUT WITHOUT STANDARD MAPPING ------------------------------------------------------------

# Declare Test - 0605 - Codes with non-standard mapping and without standard mapping take domain from concept table if not from source and vocab
declareTest(0605, "etl_procedure_occurrence inserts one event for a code with non-standard mapping in procedure domain and without standard mapping")

add_finngenid_info(
  finngenid="FG0605001"
)
add_hilmo(
  finngenid = "FG0605001",
  source = "OPER_OUT",
  code1_icd_symptom_operation_code = "AA003",
  category = "NOM3",
  index = "FG0605001-1"
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0605001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0605001"),
                                                visit_source_value = "SOURCE=OPER_OUT;INDEX=FG0605001-1"),
  procedure_concept_id = as_subquery(0),
  procedure_source_value = "AA003",
  procedure_source_concept_id = as_subquery(2001300393)
)


# TESTS CODES WITHOUT NON-STANDARD MAPPING --------------------------------------------------------------------------------------

# Declare Test - 0606 - Codes with no mapping are still added to procedure_occurrence with procedure_source_concept_id=0
declareTest(0606, "etl_procedure_occurrence adds one row in procedure_occurrence even if code in INPAT, OUTPAT, PRIM_OUT(icd or icpc) has no mapping")

add_finngenid_info(
  finngenid="FG0606001"
)
# OPER_IN
add_hilmo(
  finngenid = "FG0606001",
  source = "OPER_IN",
  code1_icd_symptom_operation_code = "-1",
  category = "NOM1",
  index = "FG0606001-1"
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0606001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0606001"),
                                                visit_source_value = "SOURCE=OPER_IN;INDEX=FG0606001-1"),
  procedure_concept_id = as_subquery(0),
  procedure_source_value = "-1",
  procedure_source_concept_id = as_subquery(0)
)

# OPER_OUT
add_hilmo(
  finngenid = "FG0606001",
  source = "OPER_OUT",
  code1_icd_symptom_operation_code = "-1",
  category = "NOM1",
  index = "FG0606001-1"
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0606001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0606001"),
                                                visit_source_value = "SOURCE=OPER_OUT;INDEX=FG0606001-1"),
  procedure_concept_id = as_subquery(0),
  procedure_source_value = "-1",
  procedure_source_concept_id = as_subquery(0)
)

# PRIM_OUT
add_prim_out(
  finngenid = "FG0606001",
  source = "PRIM_OUT",
  code1_code = "-1",
  category = "OP1",
  index = "FG0606001-1"
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0606001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0606001"),
                                                visit_source_value = "SOURCE=PRIM_OUT;INDEX=FG0606001-1"),
  procedure_concept_id = as_subquery(0),
  procedure_source_value = "-1",
  procedure_source_concept_id = as_subquery(0)
)
# PRIM_OUT
add_prim_out(
  finngenid = "FG0606001",
  source = "PRIM_OUT",
  code1_code = "-2",
  category = "MOP2",
  index = "FG0606001-1"
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0606001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0606001"),
                                                visit_source_value = "SOURCE=PRIM_OUT;INDEX=FG0606001-1"),
  procedure_concept_id = as_subquery(0),
  procedure_source_value = "-2",
  procedure_source_concept_id = as_subquery(0)
)
