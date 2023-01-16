


# Declare Test - 0201 - Non-missing APPROX_BIRTH_DATE and FU_END_AGE values
declareTest(0201, "Observation period table mappings with non-missing info from APPROX_BIRTH_DATE and FU_END_AGE columns")
add_finngenid_info(finngenid="FG0201001", sex="male",
                   bl_year = as_subquery(2000),bl_age = as_subquery(46.0),
                   approx_birth_date = "1954-03-31", fu_end_age = as_subquery(76.07))
expect_observation_period(person_id = lookup_person("person_id", person_source_value="FG0201001"),
                          observation_period_start_date = "1954-03-31", observation_period_end_date = "2030-03-31",
                          period_type_concept_id = as_subquery(32879))

# Declare Test - 0202 - APPROX_BIRTH_DATE is NULL
declareTest(0202, "Person table mappings with missing APPROX_BIRTH_DATE value")
add_finngenid_info(finngenid="FG0202001", sex="female",
                   bl_year = as_subquery(2007),bl_age = as_subquery(40.0),
                   approx_birth_date = NULL,fu_end_age = as_subquery(76.07))
expect_observation_period(person_id = lookup_person("person_id", person_source_value="FG0202001"),
                          observation_period_start_date = "1967-01-01", observation_period_end_date = "2043-01-01",
                          period_type_concept_id = as_subquery(32879))

####################################################################################################

# Declare Tests
#declareTest(101, "Observation Period mappings")
# Expect the observation period for Finngenid FG00000007
#expect_observation_period(observation_period_id = as_subquery(1), person_id = as_subquery(1),
#                          observation_period_start_date = "1954-03-31",
#                          observation_period_end_date = "2030-03-31")

# Expect the observation period for Finngenid FG00004952
#expect_observation_period(observation_period_id = as_subquery(1), person_id = as_subquery(3),
#                          observation_period_start_date = "1967-01-01",
#                          observation_period_end_date = "2043-01-01")

