






# Declare Tests
declareTest(101, "Observation Period mappings")
add_finngenid_info(finngenid="FG00000007", sex="male",
                   bl_year = as_subquery(2000),bl_age = as_subquery(46.0),
                   approx_birth_date = "1954-03-31", fu_end_age = as_subquery(76.07))
add_finngenid_info(finngenid="FG00004952", sex="male",
                   bl_year = as_subquery(2007),bl_age = as_subquery(40.0),
                   approx_birth_date = NULL,fu_end_age = as_subquery(76.07))
expect_person(person_source_value = "FG00000007", gender_concept_id = as_subquery(8507), gender_source_value = "male")
expect_person(person_source_value = "FG00000102", gender_concept_id = as_subquery(8507), gender_source_value = "male")
expect_observation_period(observation_period_id = as_subquery(1), person_id = as_subquery(2),
                          observation_period_start_date = "1954-03-31",
                          observation_period_end_date = "2021-03-31")
expect_observation_period(observation_period_id = as_subquery(1), person_id = as_subquery(3),
                          observation_period_start_date = "1967-01-01",
                          observation_period_end_date = "2043-01-01")

