







declareTest(101, "Person gender mappings")
add_covariates(fid="FG00000101", sex = "male")
add_hilmo(finngenid = "FG00000101", approx_event_day = "2000-01-01", event_age = as_subquery(10))
add_covariates(fid="FG00000102", sex = "female")
add_hilmo(finngenid = "FG00000102", approx_event_day = "2000-01-01", event_age = as_subquery(10))
add_covariates(fid="FG00000103", sex = NULL)
add_hilmo(finngenid = "FG00000103", approx_event_day = "2000-01-01", event_age = as_subquery(10))
expect_person(person_source_value = "FG00000101", gender_concept_id = as_subquery(8507), gender_source_value = "male")
expect_person(person_source_value = "FG00000102", gender_concept_id = as_subquery(8532), gender_source_value = "female")
expect_person(person_source_value = "FG00000103", gender_concept_id = as_subquery(0))

