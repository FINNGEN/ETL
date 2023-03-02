# DESCRIPTION:
# Unit tests for etl_observation.
#
# PARAMETERS:
#
# Test ids: 10xx
# Finngenids: FG10xxyyy

# Declare Test - 1001 - Default
declareTest(1001, "etl_observation works with defaults")

add_finngenid_info(
  finngenid="FG1001001"
)
add_hilmo(
  finngenid = "FG1001001",
  source = "OUTPAT",
  event_age = as_subquery(47.42),
  approx_event_day = "1994-03-08",
  code1_icd_symptom_operation_code = "W00",
  code6_speciality = "10",
  category = "EX2",
  index = "FG1001001-1")
expect_observation(
  #observation_id is rand
  person_id = lookup_person("person_id", person_source_value="FG1001001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1001001"),
                                                visit_source_value = "SOURCE=OUTPAT;INDEX=FG1001001-1"),
  observation_concept_id = as_subquery(4053863),
  observation_date = "1994-03-08",
  observation_datetime = "1994-03-08T00:00:00",
  observation_type_concept_id = as_subquery(32879),
  value_as_number = NULL,
  value_as_string = NULL,
  value_as_concept_id = NULL,
  qualifier_concept_id = NULL,
  unit_concept_id = NULL,
  provider_id = lookup_provider("provider_id", specialty_source_concept_id = as_subquery(2012000101)),
  observation_source_value = "W00",
  observation_source_concept_id = as_subquery(45756242),
  unit_source_value = NULL, qualifier_source_value = NULL, value_source_value = NULL,
  observation_event_id = NULL, obs_event_field_concept_id = NULL
)

# TESTS MAPPING CODES WITH STANDARD MAPPING  -----------------------------------------------------------------------------

# Declare Test - 1002 - Find standard for an example code in each source in HILMO and PRIM_OUT
declareTest(1002, "etl_observation adds one event for each code with standard mapping for sources in HILMO and PRIM_OUT registries")

add_finngenid_info(
  finngenid="FG1002001"
)
# INPAT
add_hilmo(
  finngenid = "FG1002001",
  source = "INPAT",
  code1_icd_symptom_operation_code = "X58",
  code2_icd_cause_na = NULL,
  icdver = "10",
  category = "EX1",
  index = "FG1002001-1"
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1002001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1002001"),
                                                visit_source_value = "SOURCE=INPAT;INDEX=FG1002001-1"),
  observation_concept_id  = as_subquery(4305831),
  observation_source_value = "X58",
  observation_source_concept_id = as_subquery(45756411)
)

# OPER_IN
add_hilmo(
  finngenid = "FG1002001",
  source = "OPER_IN",
  code1_icd_symptom_operation_code = "ZXE10",
  code2_icd_cause_na = NULL,
  category = "NOM1",
  index = "FG1002001-1"
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1002001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1002001"),
                                                visit_source_value = "SOURCE=OPER_IN;INDEX=FG1002001-1"),
  observation_concept_id = as_subquery(1175267),
  observation_source_value = "ZXE10",
  observation_source_concept_id = as_subquery(2011011401)
)

# OPER_OUT
add_hilmo(
  finngenid = "FG1002001",
  source = "OPER_OUT",
  code1_icd_symptom_operation_code = "IEY05",
  code2_icd_cause_na = NULL,
  category = "NOM1",
  index = "FG1002001-1"
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1002001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1002001"),
                                                visit_source_value = "SOURCE=OPER_OUT;INDEX=FG1002001-1"),
  observation_concept_id = as_subquery(4150859),
  observation_source_value = "IEY05",
  observation_source_concept_id = as_subquery(2011004224)
)

# OUTPAT
add_hilmo(
  finngenid = "FG1002001",
  source = "OUTPAT",
  code1_icd_symptom_operation_code = "C1623",
  code2_icd_cause_na = NULL,
  icdver = "10",
  category = "1",
  index = "FG1002001-1"
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1002001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1002001"),
                                                visit_source_value = "SOURCE=OUTPAT;INDEX=FG1002001-1"),
  observation_concept_id = as_subquery(4074210),
  observation_source_value = "C1623",
  observation_source_concept_id = as_subquery(2010000525)
)

# PRIM_OUT
add_prim_out(
  finngenid = "FG1002001",
  source = "PRIM_OUT",
  code1_code = "B28",
  icdver = NULL,
  category = "ICP1",
  index = "FG1002001-1"
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1002001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1002001"),
                                                visit_source_value = "SOURCE=PRIM_OUT;INDEX=FG1002001-1"),
  observation_concept_id = as_subquery(4137049),
  observation_source_value = "B28",
  observation_source_concept_id = as_subquery(2029000239)
)

# TESTS MAPPING CODES WITH MULTIPLE STANDARD MAPPING  -----------------------------------------------------------------------------

# Declare Test - 1003 - ICD10 code that maps to two standard codes - one condition and one observation but only outputs observation
declareTest(1003, "etl_observation adds only one event for a code with standard mapping to 2 codes one condition and one observation")

add_finngenid_info(
  finngenid="FG1003001"
)
add_prim_out(
  finngenid = "FG1003001",
  source = "PRIM_OUT",
  code1_code = "A02",
  icdver = NULL,
  category = "ICP1",
  index = "FG1003001-1"
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1003001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1003001"),
                                                visit_source_value = "SOURCE=PRIM_OUT;INDEX=FG1003001-1"),
  observation_concept_id = as_subquery(46234710),
  observation_source_value = "A02",
  observation_source_concept_id = as_subquery(2029000143)
)

# Declare Test - 1004 - NCSP code that maps to two standard codes both observation codes
declareTest(1004, "etl_observation adds two events for a code with standard mapping to two codes both observation")

add_finngenid_info(
  finngenid="FG1004001"
)
add_hilmo(
  finngenid = "FG1004001",
  source = "OUTPAT",
  code1_icd_symptom_operation_code = "V299",
  index = "FG1004001-1"
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1004001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1004001"),
                                                visit_source_value = "SOURCE=OUTPAT;INDEX=FG1004001-1"),
  observation_concept_id = as_subquery(437165),
  observation_source_value = "V299",
  observation_source_concept_id = as_subquery(45546833)
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1004001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1004001"),
                                                visit_source_value = "SOURCE=OUTPAT;INDEX=FG1004001-1"),
  observation_concept_id = as_subquery(4175576),
  observation_source_value = "V299",
  observation_source_concept_id = as_subquery(45546833)
)

# TESTS CODES WITH NON-STANDARD MAPPING BUT WITHOUT STANDARD MAPPING ------------------------------------------------------------

# Declare Test - 1005 - Codes with non-standard mapping and without standard mapping take domain from concept table if not from source and vocab
declareTest(1005, "etl_observation inserts one event for a code with non-standard mapping in procedure domain and without standard mapping")

add_finngenid_info(
  finngenid="FG1005001"
)
add_hilmo(
  finngenid = "FG1005001",
  source = "INPAT",
  code1_icd_symptom_operation_code = "01797",
  icdver = "8",
  category = "1",
  index = "FG1005001-1"
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1005001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1005001"),
                                                visit_source_value = "SOURCE=INPAT;INDEX=FG1005001-1"),
  observation_concept_id = as_subquery(0),
  observation_source_value = "01797",
  observation_source_concept_id = as_subquery(2008000250)
)

# TESTS CODES WITHOUT NON-STANDARD MAPPING --------------------------------------------------------------------------------------

# Declare Test - 1006 - Codes with no mapping are not added to observation currently with observation_concept_id=0. May change in future.
# This test will fail now but will pass in future.
declareTest(1006, "etl_observation DOESNOT insert one row in observation even if code has no mapping")

add_finngenid_info(
  finngenid="FG1006001"
)
add_hilmo(
  finngenid = "FG1006001",
  source = "OUTPAT",
  code1_icd_symptom_operation_code = "-1",
  category = "EX1",
  index = "FG1006001-1"
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1006001")
)
