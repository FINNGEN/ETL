# DESCRIPTION:
# Unit tests for etl_device_exposure.
#
# PARAMETERS:
#
# Test ids: 09xx
# Finngenids: FG09xxyyy

# Declare Test - 0901 - Default
declareTest(0901, "etl_device_exposure. works with defaults")

add_finngenid_info(
  finngenid="FG0901001"
)
add_hilmo(
  finngenid = "FG0901001",
  source = "OPER_IN",
  event_age = as_subquery(47.42),
  approx_event_day = "1994-03-08",
  code1_icd_symptom_operation_code = "TNX32",
  code6_speciality = "10",
  category = "NOM4",
  index = "FG0901001-1")
expect_device_exposure(
  #device_exposure_id is rand
  person_id = lookup_person("person_id", person_source_value="FG0901001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0901001"),
                                                visit_source_value = "SOURCE=OPER_IN;INDEX=FG0901001-1"),
  device_concept_id = as_subquery(4042424),
  device_exposure_start_date = "1994-03-08",
  device_exposure_start_datetime = "1994-03-08T00:00:00",
  device_exposure_end_date = "1994-03-08",
  device_exposure_end_datetime = "1994-03-08T00:00:00",
  device_type_concept_id = as_subquery(32879),
  unique_device_id = NULL,
  production_id = NULL,
  quantity = NULL,
  provider_id = lookup_provider("provider_id", specialty_source_concept_id = as_subquery(2001000101)),
  visit_detail_id = NULL,
  device_source_value = "TNX32",
  device_source_concept_id = as_subquery(2001308563),
  unit_concept_id = as_subquery(0),
  unit_source_value = NULL,
  unit_source_concept_id = as_subquery(0)
)

# TESTS MAPPING CODES WITH STANDARD MAPPING  -----------------------------------------------------------------------------

# Declare Test - 0902 - Find standard for an example code for OPER_IN, OPER_OUT and PRIM_OUT sources
declareTest(0902, "etl_device_exposure. adds one event for each code with standard mapping for OPER_IN, OPER_OUT and PRIM_OUT sources")

add_finngenid_info(
  finngenid="FG0902001"
)
# OPER_IN
add_hilmo(
  finngenid = "FG0902001",
  source = "OPER_IN",
  code1_icd_symptom_operation_code = "ZX121",
  code2_icd_cause_na = NULL,
  icdver = NULL,
  category = "NOM3",
  index = "FG0902001-1"
)
expect_device_exposure(
  person_id = lookup_person("person_id", person_source_value="FG0902001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0902001"),
                                                visit_source_value = "SOURCE=OPER_IN;INDEX=FG0902001-1"),
  device_concept_id = as_subquery(4179206),
  device_source_value = "ZX121",
  device_source_concept_id = as_subquery(2001311496)
)

# OPER_OUT
add_hilmo(
  finngenid = "FG0902001",
  source = "OPER_OUT",
  code1_icd_symptom_operation_code = "ZXC07",
  code2_icd_cause_na = NULL,
  category = "NOM2",
  index = "FG0902001-1"
)
expect_device_exposure(
  person_id = lookup_person("person_id", person_source_value="FG0902001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0902001"),
                                                visit_source_value = "SOURCE=OPER_OUT;INDEX=FG0902001-1"),
  device_concept_id = as_subquery(4040747),
  device_source_value = "ZXC07",
  device_source_concept_id = as_subquery(2001311357)
)

# PRIM_OUT
add_prim_out(
  finngenid = "FG0902001",
  source = "PRIM_OUT",
  code1_code = "SPC01",
  icdver = NULL,
  category = "MOP1",
  index = "FG0902001-1"
)
expect_device_exposure(
  person_id = lookup_person("person_id", person_source_value="FG0902001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0902001"),
                                                visit_source_value = "SOURCE=PRIM_OUT;INDEX=FG0902001-1"),
  device_concept_id = as_subquery(4213730),
  device_source_value = "SPC01",
  device_source_concept_id = as_subquery(2001310505)
)

# TESTS MAPPING CODES WITH MULTIPLE STANDARD MAPPING  -----------------------------------------------------------------------------

# Declare Test - 0903 - NCSP code that maps to two standard codes - one procedure and one device but only outputs device
declareTest(0903, "etl_device_exposure adds only one event for a code with standard mapping to 2 codes one procedure and one device")

add_finngenid_info(
  finngenid="FG0903001"
)
add_hilmo(
  finngenid = "FG0903001",
  source = "OPER_OUT",
  code1_icd_symptom_operation_code = "TND32",
  icdver = NULL,
  category = "NOM1",
  index = "FG0903001-1"
)
expect_device_exposure(
  person_id = lookup_person("person_id", person_source_value="FG0903001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0903001"),
                                                visit_source_value = "SOURCE=OPER_OUT;INDEX=FG0903001-1"),
  device_concept_id = as_subquery(4042424),
  device_source_value = "TND32",
  device_source_concept_id = as_subquery(2001307786)
)

# Declare Test - 0904 - NCSP code that maps to two standard codes both device codes
declareTest(0904, "etl_device_exposure adds two events for a code with standard mapping to two codes both device")

add_finngenid_info(
  finngenid="FG0904001"
)
add_hilmo(
  finngenid = "FG0904001",
  source = "OPER_IN",
  code1_icd_symptom_operation_code = "TNX39",
  icdver = NULL,
  category = "NOM1",
  index = "FG0904001-1"
)
expect_device_exposure(
  person_id = lookup_person("person_id", person_source_value="FG0904001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0904001"),
                                                visit_source_value = "SOURCE=OPER_IN;INDEX=FG0904001-1"),
  device_concept_id = as_subquery(4274503),
  device_source_value = "TNX39",
  device_source_concept_id = as_subquery(2001308566)
)
expect_device_exposure(
  person_id = lookup_person("person_id", person_source_value="FG0904001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0904001"),
                                                visit_source_value = "SOURCE=OPER_IN;INDEX=FG0904001-1"),
  device_concept_id = as_subquery(4038746),
  device_source_value = "TNX39",
  device_source_concept_id = as_subquery(2001308566)
)

# TESTS CODES WITH NON-STANDARD MAPPING BUT WITHOUT STANDARD MAPPING ------------------------------------------------------------

# Declare Test - 0905 - Codes with non-standard mapping and without standard mapping take domain from concept table if not from source and vocab
declareTest(0905, "etl_device_exposure inserts one event for a code with non-standard mapping in measurement domain and without standard mapping")

# 20230904/Anna: faulty test -> this ends up in procedure_occurrence as it should
add_finngenid_info(
  finngenid="FG0905001"
)
add_hilmo(
  finngenid = "FG0905001",
  source = "OPER_OUT",
  code1_icd_symptom_operation_code = "BA1NN",
  icdver = NULL,
  category = "NOM1",
  index = "FG0905001-1"
)
expect_device_exposure(
  person_id = lookup_person("person_id", person_source_value="FG0905001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0905001"),
                                                visit_source_value = "SOURCE=OPER_OUT;INDEX=FG0905001-1"),
  device_concept_id = as_subquery(0),
  device_source_value = "BA1NN",
  device_source_concept_id = as_subquery(2001300739)
)

# TESTS CODES WITHOUT NON-STANDARD MAPPING --------------------------------------------------------------------------------------

# Declare Test - 0906 - Codes with no mapping are not added to measurement currently with device_concept_id=0. May change in future.
# This test will fail now but will pass in future.
declareTest(0906, "etl_device_exposure DOESNOT insert one row in measurement even if code has no mapping")

add_finngenid_info(
  finngenid="FG0906001"
)
add_hilmo(
  finngenid = "FG0906001",
  source = "OPER_IN",
  code1_icd_symptom_operation_code = "-1",
  icdver = NULL,
  category = "NOM3",
  index = "FG0906001-1"
)
expect_device_exposure(
  person_id = lookup_person("person_id", person_source_value="FG0906001")
)
