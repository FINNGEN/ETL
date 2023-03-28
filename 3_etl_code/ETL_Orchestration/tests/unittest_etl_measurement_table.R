# DESCRIPTION:
# Unit tests for etl_measurement.
#
# PARAMETERS:
#
# Test ids: 08xx
# Finngenids: FG08xxyyy

# Declare Test - 0801 - Default
declareTest(0801, "etl_measurement. works with defaults")

add_finngenid_info(
  finngenid="FG0801001"
)
add_hilmo(
  finngenid = "FG0801001",
  source = "INPAT",
  event_age = as_subquery(47.42),
  approx_event_day = "1994-03-08",
  code1_icd_symptom_operation_code = "Z015",
  code6_speciality = "10",
  category = "3",
  index = "FG0801001-1")
expect_measurement(
  #measurement_id is rand
  person_id = lookup_person("person_id", person_source_value="FG0801001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0801001"),
                                                visit_source_value = "SOURCE=INPAT;INDEX=FG0801001-1"),
  measurement_concept_id = as_subquery(4092969),
  measurement_date = "1994-03-08",
  measurement_datetime = "1994-03-08T00:00:00",
  measurement_time = "00:00:00",
  measurement_type_concept_id = as_subquery(32879),
  operator_concept_id = as_subquery(0),
  value_as_number = NULL,
  value_as_concept_id = as_subquery(0),
  unit_concept_id = as_subquery(0),
  range_low = NULL,
  range_high = NULL,
  provider_id = lookup_provider("provider_id", specialty_source_concept_id = as_subquery(2001000101)),
  visit_detail_id = NULL,
  measurement_source_value = "Z015",
  measurement_source_concept_id = as_subquery(45590690),
  unit_source_value = NULL,
  unit_source_concept_id = as_subquery(0),
  value_source_value = NULL,
  measurement_event_id = NULL,
  meas_event_field_concept_id = as_subquery(0)
)

# TESTS MAPPING CODES WITH STANDARD MAPPING  -----------------------------------------------------------------------------

# Declare Test - 0802 - Find standard for an example code in each source in HILMO and PRIM_OUT
declareTest(0802, "etl_measurement adds one event for each code with standard mapping for sources in HILMO and PRIM_OUT registries")

add_finngenid_info(
  finngenid="FG0802001"
)
# INPAT
add_hilmo(
  finngenid = "FG0802001",
  source = "INPAT",
  code1_icd_symptom_operation_code = "Z015",
  code2_icd_cause_na = NULL,
  icdver = "10",
  category = "3",
  index = "FG0802001-1"
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG0802001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0802001"),
                                                visit_source_value = "SOURCE=INPAT;INDEX=FG0802001-1"),
  measurement_concept_id  = as_subquery(4092969),
  measurement_source_value = "Z015",
  measurement_source_concept_id = as_subquery(45590690)
)

# OPER_IN
add_hilmo(
  finngenid = "FG0802001",
  source = "OPER_IN",
  code1_icd_symptom_operation_code = "TFP30",
  code2_icd_cause_na = NULL,
  category = "NOM1",
  index = "FG0802001-1"
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG0802001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0802001"),
                                                visit_source_value = "SOURCE=OPER_IN;INDEX=FG0802001-1"),
  measurement_concept_id = as_subquery(3010322),
  measurement_source_value = "TFP30",
  measurement_source_concept_id = as_subquery(2001303225)
)

# OPER_OUT
add_hilmo(
  finngenid = "FG0802001",
  source = "OPER_OUT",
  code1_icd_symptom_operation_code = "XKD00",
  code2_icd_cause_na = NULL,
  category = "NOM2",
  index = "FG0802001-1"
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG0802001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0802001"),
                                                visit_source_value = "SOURCE=OPER_OUT;INDEX=FG0802001-1"),
  measurement_concept_id = as_subquery(4261340),
  measurement_source_value = "XKD00",
  measurement_source_concept_id = as_subquery(2001306096)
)

# OUTPAT
add_hilmo(
  finngenid = "FG0802001",
  source = "OUTPAT",
  code1_icd_symptom_operation_code = "Z363",
  code2_icd_cause_na = NULL,
  icdver = "10",
  category = "1",
  index = "FG0802001-1"
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG0802001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0802001"),
                                                visit_source_value = "SOURCE=OUTPAT;INDEX=FG0802001-1"),
  measurement_concept_id = as_subquery(36713462),
  measurement_source_value = "Z363",
  measurement_source_concept_id = as_subquery(45581023)
)

# PRIM_OUT
add_prim_out(
  finngenid = "FG0802001",
  source = "PRIM_OUT",
  code1_code = "Z017",
  category = "ICD1",
  index = "FG0802001-1"
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG0802001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0802001"),
                                                visit_source_value = "SOURCE=PRIM_OUT;INDEX=FG0802001-1"),
  measurement_concept_id = as_subquery(4034850),
  measurement_source_value = "Z017",
  measurement_source_concept_id = as_subquery(45556809)
)

# TESTS MAPPING CODES WITH MULTIPLE STANDARD MAPPING  -----------------------------------------------------------------------------

# Declare Test - 0803 - ICD10 code that maps to two standard codes - one procedure and one measurement but only outputs measurement
declareTest(0803, "etl_measurement adds only one event for a code with standard mapping to 2 codes one procedure and one measurement")

add_finngenid_info(
  finngenid="FG0803001"
)
add_hilmo(
  finngenid = "FG0803001",
  source = "OPER_OUT",
  code1_icd_symptom_operation_code = "SBA10",
  icdver = NULL,
  category = "NOM3",
  index = "FG0803001-1"
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG0803001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0803001"),
                                                visit_source_value = "SOURCE=OPER_OUT;INDEX=FG0803001-1"),
  measurement_concept_id = as_subquery(4210308),
  measurement_source_value = "SBA10",
  measurement_source_concept_id = as_subquery(2001310295)
)

# Declare Test - 0804 - NCSP code that maps to two standard codes both measurement codes
declareTest(0804, "etl_measurement adds two events for a code with standard mapping to two codes both measurement")

add_finngenid_info(
  finngenid="FG0804001"
)
add_hilmo(
  finngenid = "FG0804001",
  source = "OPER_IN",
  code1_icd_symptom_operation_code = "XQ831",
  category = "NOM1",
  index = "FG0804001-1"
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG0804001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0804001"),
                                                visit_source_value = "SOURCE=OPER_IN;INDEX=FG0804001-1"),
  measurement_concept_id = as_subquery(4092969),
  measurement_source_value = "XQ831",
  measurement_source_concept_id = as_subquery(2001310101)
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG0804001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0804001"),
                                                visit_source_value = "SOURCE=OPER_IN;INDEX=FG0804001-1"),
  measurement_concept_id = as_subquery(4091609),
  measurement_source_value = "XQ831",
  measurement_source_concept_id = as_subquery(2001310101)
)

# TESTS CODES WITH NON-STANDARD MAPPING BUT WITHOUT STANDARD MAPPING ------------------------------------------------------------

# Declare Test - 0805 - Codes with non-standard mapping and without standard mapping take domain from concept table if not from source and vocab
declareTest(0805, "etl_measurement inserts one event for a code with non-standard mapping in measurement domain and without standard mapping")

add_finngenid_info(
  finngenid="FG0805001"
)
add_hilmo(
  finngenid = "FG0805001",
  source = "INPAT",
  code1_icd_symptom_operation_code = "78719",
  icdver = "8",
  category = "1",
  index = "FG0805001-1"
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG0805001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0805001"),
                                                visit_source_value = "SOURCE=INPAT;INDEX=FG0805001-1"),
  measurement_concept_id = as_subquery(0),
  measurement_source_value = "78719",
  measurement_source_concept_id = as_subquery(2000305261)
)

# TESTS CODES WITHOUT NON-STANDARD MAPPING --------------------------------------------------------------------------------------

# Declare Test - 0806 - Codes with no mapping are not added to measurement currently with measurement_concept_id=0. May change in future.
# This test will fail now but will pass in future.
declareTest(0806, "etl_measurement DOESNOT insert one row in measurement even if code has no mapping")

add_finngenid_info(
  finngenid="FG0806001"
)
add_hilmo(
  finngenid = "FG0806001",
  source = "OPER_OUT",
  code1_icd_symptom_operation_code = "-1",
  icdver = NULL,
  category = "EX1",
  index = "FG0806001-1"
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG0806001")
)
