






# Declare Tests
declareTest(101, "Observation Period mappings")
# Expect the observation period
expect_observation_period(observation_period_id = as_subquery(1), person_id = as_subquery(1),
                          observation_period_start_date = "1954-03-31",
                          observation_period_end_date = "2021-03-31")
expect_observation_period(observation_period_id = as_subquery(1), person_id = as_subquery(3),
                          observation_period_start_date = "1967-01-01",
                          observation_period_end_date = "2043-01-01")

