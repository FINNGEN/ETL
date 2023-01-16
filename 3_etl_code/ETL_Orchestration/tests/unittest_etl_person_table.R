






# Declare Test - 0101 - Non-missing APPROX_BIRTH_DATE value
declareTest(0101, "Person table mappings with non-missing info from APPROX_BIRTH_DATE column")
add_finngenid_info(finngenid="FG0101001", sex="male",
                   bl_year = as_subquery(2000),bl_age = as_subquery(46.0),
                   approx_birth_date = "1954-03-31", fu_end_age = as_subquery(76.07))
expect_person(person_source_value = "FG0101001", gender_concept_id = as_subquery(8507), gender_source_value = "male",
              birth_datetime = "1954-03-31T00:00:00", year_of_birth = as_subquery(1954), month_of_birth = as_subquery(3), day_of_birth = as_subquery(31),
              race_concept_id = as_subquery(4005076), ethnicity_concept_id = as_subquery(38003564))

# Declare Test - 0102 - APPROX_BIRTH_DATE is NULL
declareTest(0102, "Person table mappings with missing APPROX_BIRTH_DATE value")
add_finngenid_info(finngenid="FG0102001", sex="female",
                   bl_year = as_subquery(2007),bl_age = as_subquery(40.0),
                   approx_birth_date = NULL,fu_end_age = as_subquery(76.07))
expect_person(person_source_value = "FG0102001", gender_concept_id = as_subquery(8532), gender_source_value = "female",
              birth_datetime = "1967-01-01T00:00:00", year_of_birth = as_subquery(1967), month_of_birth = as_subquery(1), day_of_birth = as_subquery(1),
              race_concept_id = as_subquery(4005076), ethnicity_concept_id = as_subquery(38003564))

# Declare Test - 0103 - SEX is NULL
declareTest(0103, "Person table mappings for gender value NULL")
add_finngenid_info(finngenid="FG0103001", sex=NULL, approx_birth_date = "1959-01-01")
expect_person(person_source_value = "FG0103001", gender_concept_id = as_subquery(0), gender_source_value = NULL,
              birth_datetime = "1959-01-01T00:00:00", year_of_birth = as_subquery(1959), month_of_birth = as_subquery(1), day_of_birth = as_subquery(1),
              race_concept_id = as_subquery(4005076), ethnicity_concept_id = as_subquery(38003564))

##############################################################################

#add_covariates(fid="FG00000200", sex = "male")
#add_hilmo(finngenid = "FG00000101", approx_event_day = "2000-01-01", event_age = as_subquery(10))
#add_covariates(fid="FG00000102", sex = "female")
#add_hilmo(finngenid = "FG00000102", approx_event_day = "2000-01-01", event_age = as_subquery(10))
#add_covariates(fid="FG00000103", sex = NULL)
#add_hilmo(finngenid = "FG00000103", approx_event_day = "2000-01-01", event_age = as_subquery(10))


#expect_person(person_source_value = "FG00000102", gender_concept_id = as_subquery(8532), gender_source_value = "female")
#expect_person(person_source_value = "FG00000103", gender_concept_id = as_subquery(0))

