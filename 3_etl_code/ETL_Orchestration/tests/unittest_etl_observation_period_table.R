






# Declare Tests
declareTest(101, "Observation Period mappings")
# Expect the observation period for Finngenid FG00000007
expect_observation_period(observation_period_id = as_subquery(1), person_id = as_subquery(1),
                          observation_period_start_date = "1954-03-31",
                          observation_period_end_date = "2030-03-31")

# Expect the observation period for Finngenid FG00004952
expect_observation_period(observation_period_id = as_subquery(1), person_id = as_subquery(3),
                          observation_period_start_date = "1967-01-01",
                          observation_period_end_date = "2043-01-01")

