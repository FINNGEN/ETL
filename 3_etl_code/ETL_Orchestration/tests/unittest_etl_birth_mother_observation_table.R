# DESCRIPTION:
# Unit tests for etl_birth_mother for observation table.
# For this unit test PLEASE add other registry event
# apart from BIRTH_MOTHER registry for visit_occurrence table
# through which these tables are filled out.
# PARAMETERS:
#
# Test ids: 15xx
# Finngenids: FG015xxyyy

# Declare Test - 1501 - Find standard condition code in birth mother registry
declareTest(1501, "etl_observation adds one row for code with standard mapping for source birth_mother")

add_finngenid_info(
  finngenid="FG1501001"
)
# INPAT
add_hilmo(
  finngenid = "FG1501001",
  source = "INPAT",
  index = "FG1501001-1"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1501001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "Z348"
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1501001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1501001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  observation_concept_id = as_subquery(4047564),
  observation_source_value = "Z348",
  observation_source_concept_id = as_subquery(45537628)
)

# Declare Test - 1502 - Mother with two diagnosis codes that are non-null and both fall in measurement domain
declareTest(1502, "etl_observation adds two rows for two diagnosis codes with standard mapping in measurement domain for source birth_mother")

add_finngenid_info(
  finngenid="FG1502001"
)
# OUTPAT
add_hilmo(
  finngenid = "FG1502001",
  source = "OUTPAT",
  index = "FG1502001-1"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1502001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "Z340",
  sdiag2 = "Z392"
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1502001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1502001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  observation_concept_id = as_subquery(4061424),
  observation_source_value = "Z340",
  observation_source_concept_id = as_subquery(45595500)
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1502001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1502001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  observation_concept_id = as_subquery(36713471),
  observation_source_value = "Z392",
  observation_source_concept_id = as_subquery(45547306)
)

# Declare Test - 1503 - Mother with two diagnosis codes that are non-null but one has standard map in observation and other in condition

# Declare Test - 1504 - Mother with diagnosis code that is non-null but has standard maps to both observation and condition domain

