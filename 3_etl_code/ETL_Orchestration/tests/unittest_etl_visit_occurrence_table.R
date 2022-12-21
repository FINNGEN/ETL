

# Declare Test - 0301 - PURCH registry
declareTest(0301, "Visit Occurrence table mappings for PURCH registry with tablet dose form and differing CODE4 pakcage info for different visits")
# Add Finngenid_info
add_finngenid_info(finngenid="FG0301001", sex="male",
                   bl_year = as_subquery(2000),bl_age = as_subquery(46.0),
                   approx_birth_date = "1954-03-31", fu_end_age = as_subquery(76.07))
# Add PURCH registry
add_purch(finngenid = "FG0301001", source = "PURCH",event_age = as_subquery(56.0), approx_event_day = "2010-03-31",
          code1_atc_code = "S01ED51", code3_vnro = "068220" )
add_purch(finngenid = "FG0301001", source = "PURCH", event_age = as_subquery(57.3), approx_event_day = "2011-06-01",
          code1_atc_code = "J01CR02", code3_vnro = "1154", code4_plkm = "2" )


add_purch(finngenid = "FG00000200", source = "PURCH", event_age = as_subquery(41.2), approx_event_day = "2019-01-01",
          code1_atc_code = "J02AC02", code3_vnro = "152991", code4_plkm = "2" )
add_purch(finngenid = "FG00000200", source = "PURCH", event_age = as_subquery(41.2), approx_event_day = "2020-10-01",
          code3_vnro = "144493" )



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
declareTest(101, "Visit Occurrence mappings")
# Expect the visit occurrence
expect_visit_occurrence(person_id = as_subquery(1),visit_occurrence_id = as_subquery(1),
                        visit_start_date = "2010-03-31",
                        visit_concept_id = as_subquery(4000000007),visit_source_value = "PURCH",
                        visit_type_concept_id = as_subquery(32879),
                        visit_end_date = "2010-04-01")
expect_visit_occurrence(person_id = as_subquery(1),visit_occurrence_id = as_subquery(2),
                        visit_start_date = "2011-06-01",
                        visit_concept_id = as_subquery(4000000007),visit_source_value = "PURCH",
                        visit_type_concept_id = as_subquery(32879),
                        visit_end_date = "2011-06-02")
expect_visit_occurrence(person_id = as_subquery(2),visit_occurrence_id = as_subquery(1),
                        visit_start_date = "2019-01-01",
                        visit_concept_id = as_subquery(4000000007),visit_source_value = "PURCH",
                        visit_type_concept_id = as_subquery(32879),
                        visit_end_date = "2019-01-02")
expect_visit_occurrence(person_id = as_subquery(2),visit_occurrence_id = as_subquery(2),
                        visit_start_date = "2020-10-01",
                        visit_concept_id = as_subquery(4000000007),visit_source_value = "PURCH",
                        visit_type_concept_id = as_subquery(32879),
                        visit_end_date = "2020-10-02")

