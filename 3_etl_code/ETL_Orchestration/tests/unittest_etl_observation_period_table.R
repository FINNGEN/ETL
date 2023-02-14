# DESCRIPTION:
# Unit tests for etl_observation_period.
# The first test is to check whether default values of person table are set properly.
# Rest of the tests follow checking different columns and how they are processed.
#
# PARAMETERS:
#
# Test ids: 02xx
# Finngenids: FG0020xxyyy


# Declare Test - 0201 - default values
declareTest(0201, "etl_observation_period_table sets default values correctly")
add_finngenid_info(
  finngenid="FG00201001",
  sex="male",
  approx_birth_date = "1954-03-31",
  fu_end_age = as_subquery(20.5)
)
expect_observation_period(
  observation_period_id = lookup_person("person_id", person_source_value="FG00201001"),
  person_id = lookup_person("person_id", person_source_value="FG00201001"),
  observation_period_start_date = "1954-03-31",
  observation_period_end_date = "1974-09-30",
  period_type_concept_id = as_subquery(32879)
)

# Declare Test - 0202 -
declareTest(0202, "etl_observation_period_table sets 1953-01-01 when brithday before 1953")
add_finngenid_info(
  finngenid="FG00202001",
  approx_birth_date = "1952-03-31",
  fu_end_age = as_subquery(76.20)
)
expect_observation_period(
  person_id = lookup_person("person_id", person_source_value="FG00202001"),
  observation_period_start_date = "1953-01-01",
  observation_period_end_date = "2028-06-12",
  period_type_concept_id = as_subquery(32879)
)


# Declare Test - 0203
declareTest(0203, "etl_observation_period_table sets 2023-01-15 when fu_end_age is null")
add_finngenid_info(
  finngenid="FG00203001",
  approx_birth_date = "1952-03-31",
  fu_end_age = NULL
)
expect_observation_period(
  person_id = lookup_person("person_id", person_source_value="FG00203001"),
  observation_period_start_date = "1953-01-01",
  observation_period_end_date = "2023-01-15",
  period_type_concept_id = as_subquery(32879)
)

#
# # Declare Test - 0201 - default values
# declareTest(0201, "Observation period table mappings with non-missing info from APPROX_BIRTH_DATE and FU_END_AGE columns")
# add_finngenid_info(
#   finngenid="FG00201001",
#   sex="male",
#   approx_birth_date = "1954-03-31",
#   fu_end_age = as_subquery(76.07)
# )
# expect_observation_period(
#   observation_period_id = lookup_person("person_id", person_source_value="FG00201001"),
#   person_id = lookup_person("person_id", person_source_value="FG00201001"),
#   observation_period_start_date = "1954-03-31",
#   observation_period_end_date = "2030-03-31",
#   period_type_concept_id = as_subquery(32879)
# )
#
# # # Declare Test - 0202 - APPROX_BIRTH_DATE is NULL
# # declareTest(0202, "Person table mappings with missing APPROX_BIRTH_DATE value")
# # add_finngenid_info(finngenid="FG0202001", sex="female",
# #                    bl_year = as_subquery(2007),bl_age = as_subquery(40.0),
# #                    approx_birth_date = NULL,fu_end_age = as_subquery(76.07))
# expect_observation_period(person_id = lookup_person("person_id", person_source_value="FG0202001"),
#                           observation_period_start_date = "1967-01-01", observation_period_end_date = "2043-01-01",
#                           period_type_concept_id = as_subquery(32879))
#
#
