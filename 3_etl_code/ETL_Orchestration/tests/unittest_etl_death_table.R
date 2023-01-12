

# Declare Test - 0701 - Death registry entry with category for cause of death
declareTest(0701, "Death registry entry with category for cause of death")
add_finngenid_info(finngenid="FG0701001", sex="female",
                   bl_year = as_subquery(2010),bl_age = as_subquery(56.0),
                   approx_birth_date = "1944-03-31", fu_end_age = as_subquery(66.07))
# Add DEATH registry
add_death(finngenid = "FG0701001", source = "DEATH", event_age = as_subquery(72.31), approx_event_day = "2020-03-25",
          code1_cause_of_death = "I482", icdver = "10", category = "I", index = "701")
add_death(finngenid = "FG0701001", source = "DEATH", event_age = as_subquery(72.31), approx_event_day = "2020-03-25",
          code1_cause_of_death = "E112", icdver = "10", category = "U", index = "701")
add_death(finngenid = "FG0701001", source = "DEATH", event_age = as_subquery(72.31), approx_event_day = "2020-03-25",
          code1_cause_of_death = "I10", icdver = "10", category = "c1", index = "701")
# Expect Death
expect_death(person_id = lookup_person("person_id", person_source_value = "FG0701001"),
             death_date = "2020-03-25", death_datetime = "2020-03-25T00:00:00",
             death_type_concept_id = as_subquery(32879),
             cause_concept_id = as_subquery(4141360), cause_source_value = "I482", cause_source_concept_id = as_subquery(45591467)
             )
expect_death(person_id = lookup_person("person_id", person_source_value = "FG0701001"),
             death_date = "2020-03-25", death_datetime = "2020-03-25T00:00:00",
             death_type_concept_id = as_subquery(32879),
             cause_concept_id = as_subquery(0), cause_source_value = "E112", cause_source_concept_id = as_subquery(45605400)
)
expect_death(person_id = lookup_person("person_id", person_source_value = "FG0701001"),
             death_date = "2020-03-25", death_datetime = "2020-03-25T00:00:00",
             death_type_concept_id = as_subquery(32879),
             cause_concept_id = as_subquery(0), cause_source_value = "I10", cause_source_concept_id = as_subquery(45591453)
)

# Declare Test - 0702 - Death registry entry with no immediate cause but has underlying cause
declareTest(0702, "Death registry entry with no immediate cause but has underlying cause")
add_finngenid_info(finngenid="FG0702001", sex="male",
                   bl_year = as_subquery(1995),bl_age = as_subquery(55.0),
                   approx_birth_date = "1940-05-17", fu_end_age = as_subquery(75.07))
# Add DEATH registry
add_death(finngenid = "FG0702001", source = "DEATH", event_age = as_subquery(75.07), approx_event_day = "2015-05-24",
          code1_cause_of_death = "J189", icdver = "10", category = "U", index = "702")
# Expect Death
expect_death(person_id = lookup_person("person_id", person_source_value = "FG0702001"),
             death_date = "2015-05-24", death_datetime = "2015-05-24T00:00:00",
             death_type_concept_id = as_subquery(32879),
             cause_concept_id = as_subquery(0), cause_source_value = "J189", cause_source_concept_id = as_subquery(45601123)
)

# Declare Test - 0703 - Death registry entry with no category for cause of death
declareTest(0703, "Death registry entry with no category for cause of death")
add_finngenid_info(finngenid="FG0703001", sex="female",
                   bl_year = as_subquery(2005),bl_age = as_subquery(65.0),
                   approx_birth_date = "1940-08-12", fu_end_age = as_subquery(72.32))
# Add DEATH registry
add_death(finngenid = "FG0703001", source = "DEATH", event_age = as_subquery(72.32), approx_event_day = "2012-09-14",
          code1_cause_of_death = "I10", icdver = "10", index = "703")
add_death(finngenid = "FG0703001", source = "DEATH", event_age = as_subquery(72.32), approx_event_day = "2012-09-14",
          code1_cause_of_death = "I212", icdver = "10", index = "703")
# Expect Death
expect_death(person_id = lookup_person("person_id", person_source_value = "FG0703001"),
             death_date = "2012-09-14", death_datetime = "2012-09-14T00:00:00",
             death_type_concept_id = as_subquery(32879),
             cause_concept_id = as_subquery(0), cause_source_value = "I10", cause_source_concept_id = as_subquery(45591453)
)
expect_death(person_id = lookup_person("person_id", person_source_value = "FG0703001"),
             death_date = "2012-09-14", death_datetime = "2012-09-14T00:00:00",
             death_type_concept_id = as_subquery(32879),
             cause_concept_id = as_subquery(0), cause_source_value = "I212", cause_source_concept_id = as_subquery(45596190)
)
