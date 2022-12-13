






# Declare Tests
declareTest(101, "Person gender mappings")
# Add the Person Info
add_finngenid_info(finngenid="FG00000007", sex="male",
                   bl_year = as_subquery(2000),bl_age = as_subquery(46.0),
                   approx_birth_date = "1954-03-31", fu_end_age = as_subquery(76.07))
add_finngenid_info(finngenid="FG00000200", sex="male")
add_finngenid_info(finngenid="FG00004952", sex="female",
                   bl_year = as_subquery(2007),bl_age = as_subquery(40.0),
                   approx_birth_date = NULL,fu_end_age = as_subquery(76.07))
# Add PURCH registry
add_purch(finngenid = "FG00000007", source = "PURCH",event_age = as_subquery(56.0), approx_event_day = "2010-03-31",
          code1_atc_code = "S01ED51", code3_vnro = "068220" )
add_purch(finngenid = "FG00000007", source = "PURCH", event_age = as_subquery(57.3), approx_event_day = "2011-06-01",
          code1_atc_code = "J01CR02", code3_vnro = "1154", code4_plkm = "2" )
add_purch(finngenid = "FG00000200", source = "PURCH", event_age = as_subquery(41.2), approx_event_day = "2019-01-01",
          code1_atc_code = "J02AC02", code3_vnro = "152991", code4_plkm = "2" )
add_purch(finngenid = "FG00000200", source = "PURCH", event_age = as_subquery(41.2), approx_event_day = "2020-10-01",
          code3_vnro = "144493" )
#add_covariates(fid="FG00000200", sex = "male")
#add_hilmo(finngenid = "FG00000101", approx_event_day = "2000-01-01", event_age = as_subquery(10))
#add_covariates(fid="FG00000102", sex = "female")
#add_hilmo(finngenid = "FG00000102", approx_event_day = "2000-01-01", event_age = as_subquery(10))
#add_covariates(fid="FG00000103", sex = NULL)
#add_hilmo(finngenid = "FG00000103", approx_event_day = "2000-01-01", event_age = as_subquery(10))
# Expect the Person Info
expect_person(person_source_value = "FG00000007", gender_concept_id = as_subquery(8507), gender_source_value = "male")
expect_person(person_source_value = "FG00000200", gender_concept_id = as_subquery(8507), gender_source_value = "male")
expect_person(person_source_value = "FG00004952", gender_concept_id = as_subquery(8532), gender_source_value = "female")
#expect_person(person_source_value = "FG00000102", gender_concept_id = as_subquery(8532), gender_source_value = "female")
#expect_person(person_source_value = "FG00000103", gender_concept_id = as_subquery(0))

