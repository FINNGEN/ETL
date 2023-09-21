# DESCRIPTION:
# Unit tests for etl_vision for condition and measurement tables.
#
# PARAMETERS:
#
# Condition Occurrence
# Test ids: 19xx
# Finngenids: FG019xxyyy
#
# Measurement
# Test ids: 20xx
# Finngenids: FG020xxyyy


# CONDITION OCCURRENCE ------------------------------------------------------------------------------------

# Declare Test - 1901 - Default values
declareTest(1901, "etl_condition_occurrence adds a row for default values for source vision")

add_finngenid_info(
  finngenid="FG1901001"
)
# VISION
add_vision(
  finngenid = "FG1901001"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1901001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1901001"),
                                                visit_source_value = "SOURCE=VISION;INDEX="),
  condition_concept_id = as_subquery(372629),
  condition_source_value = "CODE1=362.51;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(44837028)
)

# Declare Test - 1902 - Find standard condition code in vision registry
declareTest(1902, "etl_condition_occurrence adds one row for code with standard mapping for source vision")

add_finngenid_info(
  finngenid="FG1902001"
)
# VISION
add_vision(
  finngenid = "FG1902001",
  diagn1 = "37931"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1902001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1902001"),
                                                visit_source_value = "SOURCE=VISION;INDEX="),
  condition_concept_id = as_subquery(381033),
  condition_source_value = "CODE1=379.31;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(44824209)
)

# Declare Test - 1903 - Finds parent icd9cm code when input icd9cm code does not exist
declareTest(1903, "etl_condition_occurrence adds a row for parent icd9cm code with standard mapping for source vision when original code does not exist")

add_finngenid_info(
  finngenid="FG1903001"
)
# VISION
add_vision(
  finngenid = "FG1903001",
  diagn1 = "22400"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1903001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1903001"),
                                                visit_source_value = "SOURCE=VISION;INDEX="),
  condition_concept_id = as_subquery(381252),
  condition_source_value = "CODE1=224.0;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(44825248)
)

# Declare Test - 1904 - Vision visit with two icd9cm diagnosis codes that are non-null
declareTest(1904, "etl_condition_occurrence adds two rows for two icd9cm diagnosis codes with standard mapping for source vision")

add_finngenid_info(
  finngenid="FG1904001"
)
# VISION
add_vision(
  finngenid = "FG1904001",
  event_age = as_subquery(47.26),
  diagn1 = "36250",
  diagn2 = "36251"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1904001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1904001"),
                                                visit_source_value = "SOURCE=VISION;INDEX="),
  condition_concept_id = as_subquery(374028),
  condition_source_value = "CODE1=362.50;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(44823043)
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1904001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1904001"),
                                                visit_source_value = "SOURCE=VISION;INDEX="),
  condition_concept_id = as_subquery(372629),
  condition_source_value = "CODE1=362.51;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(44837028)
)

# Declare Test - 1905 - Vision visit with a icd9cm and a icd10 diagnosis codes that are non-null
declareTest(1905, "etl_condition_occurrence adds two rows for icd9cm and icd10 diagnosis codes with standard mapping for source vision")

add_finngenid_info(
  finngenid="FG1905001"
)
# VISION
add_vision(
  finngenid = "FG1905001",
  event_age = as_subquery(47.26),
  diagn1 = "36200",
  diagn4 = "H541"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1905001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1905001"),
                                                visit_source_value = "SOURCE=VISION;INDEX="),
  condition_concept_id = as_subquery(4174977),
  condition_source_value = "CODE1=362.0;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(44826573)
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1905001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1905001"),
                                                visit_source_value = "SOURCE=VISION;INDEX="),
  condition_concept_id = as_subquery(44806788),
  condition_source_value = "CODE1=H54.1;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(45538321)
)

# Declare Test - 1906 - visual acuity column combination maps to proper ICD10 diagnosis code
declareTest(1906, "etl_condition_occurrence adds a row for visual acuity combination ICD10 code with standard mapping for source vision")

add_finngenid_info(
  finngenid="FG1906001"
)
# VISION
add_vision(
  finngenid = "FG1906001",
  event_age = as_subquery(47.26),
  ovisus = as_subquery(6),
  vvisus = as_subquery(1)
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1906001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1906001"),
                                                visit_source_value = "SOURCE=VISION;INDEX="),
  condition_concept_id = as_subquery(4023310),
  condition_source_value = "CODE1=H544;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(45605715)
)

# Declare Test - 1907 - Homonymous Hemianopsia properly mapped
declareTest(1907, "etl_condition_occurrence adds a row for homonymous hemianopsia with standard mapping for source vision")

add_finngenid_info(
  finngenid="FG1907001"
)
# VISION
add_vision(
  finngenid = "FG1907001",
  event_age = as_subquery(47.26),
  ohemia = as_subquery(1),
  vhemia = as_subquery(1)
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1907001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1907001"),
                                                visit_source_value = "SOURCE=VISION;INDEX="),
  condition_concept_id = as_subquery(4184148),
  condition_source_value = "CODE1=5591009;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(3410836)
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1907001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1907001"),
                                                visit_source_value = "SOURCE=VISION;INDEX="),
  condition_concept_id = as_subquery(4205568),
  condition_source_value = "CODE1=55634009;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(3290497)
)

# MEASUREMENT ----------------------------------------------------------------------------------------------------------------

# Declare Test - 2001 - Find standard measurement code in vision registry
declareTest(2001, "etl_measurement adds a row with non-standard code for right eye visual field diameter and no standard code for source vision")

add_finngenid_info(
  finngenid="FG2001001"
)
# VISION
add_vision(
  finngenid = "FG2001001",
  event_age = as_subquery(47.26),
  ohalk = as_subquery(2)
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG2001001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG2001001"),
                                                visit_source_value = "SOURCE=VISION;INDEX="),
  measurement_concept_id = as_subquery(0),
  operator_concept_id = as_subquery(4171754),
  value_as_number = as_subquery(5),
  unit_concept_id = as_subquery(9484),
  measurement_source_value = "VFDRE",
  measurement_source_concept_id = as_subquery(2002330120),
  unit_source_value = "degrees of arc",
  unit_source_concept_id = as_subquery(4118328)
)

# Declare Test - 2002 - Add visual field diameter left eye
declareTest(2002, "etl_measurement adds a row with non-standard code for left eye visual field diameter and no standard code for source vision")

add_finngenid_info(
  finngenid="FG2002001"
)
# VISION
add_vision(
  finngenid = "FG2002001",
  event_age = as_subquery(47.26),
  vhalk = as_subquery(6)
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG2002001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG2002001"),
                                                visit_source_value = "SOURCE=VISION;INDEX="),
  measurement_concept_id = as_subquery(0),
  operator_concept_id = as_subquery(4172704),
  value_as_number = as_subquery(60),
  unit_concept_id = as_subquery(9484),
  measurement_source_value = "VFDLE",
  measurement_source_concept_id = as_subquery(2002330121),
  unit_source_value = "degrees of arc",
  unit_source_concept_id = as_subquery(4118328)
)

# Declare Test - 2003 - Does not add a row when both visual field diameter columns are missing
declareTest(2003, "etl_measurement DOESNOT add a row for source vision with both visual fields being null")

add_finngenid_info(
  finngenid="FG2003001"
)
# VISION
add_vision(
  finngenid = "FG2003001"
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG2003001")
)



