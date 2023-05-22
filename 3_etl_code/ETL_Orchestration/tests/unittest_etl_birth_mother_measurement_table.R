# DESCRIPTION:
# Unit tests for etl_birth_mother for measurement table.
# For this unit test PLEASE add other registry event
# apart from BIRTH_MOTHER registry for visit_occurrence table
# through which these tables are filled out.
# PARAMETERS:
#
# Test ids: 14xx
# Finngenids: FG014xxyyy

# Declare Test - 1401 - Find standard condition code in birth mother registry
declareTest(1401, "etl_measurement adds one row for code with standard mapping for birth mother")

add_finngenid_info(
  finngenid="FG1401001"
)
# INPAT
add_hilmo(
  finngenid = "FG1401001",
  source = "INPAT",
  index = "FG1401001-1"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1401001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "Z363"
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG1401001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1401001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  measurement_concept_id = as_subquery(36713462),
  measurement_source_value = "Z363",
  measurement_source_concept_id = as_subquery(45581023)
)

# Declare Test - 1402 - Mother with two diagnosis codes that are non-null and both fall in measurement domain
declareTest(1402, "etl_measurement adds two rows for two diagnosis codes with standard mapping in measurement domain for source birth_mother")

add_finngenid_info(
  finngenid="FG1402001"
)
# OUTPAT
add_hilmo(
  finngenid = "FG1402001",
  source = "OUTPAT",
  index = "FG1402001-1"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1402001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "Z360",
  sdiag2 = "Z368"
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG1402001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1402001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  measurement_concept_id = as_subquery(43020943),
  measurement_source_value = "Z360",
  measurement_source_concept_id = as_subquery(45571345)
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG1402001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1402001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  measurement_concept_id = as_subquery(4087235),
  measurement_source_value = "Z368",
  measurement_source_concept_id = as_subquery(45542422)
)

# Declare Test - 1403 - Mother with two diagnosis codes that are non-null but one has standard map in measurement and other in procedure

# Declare Test - 1404 - Mother with diagnosis code that is non-null but has standard maps to both measurement and procedure domain

