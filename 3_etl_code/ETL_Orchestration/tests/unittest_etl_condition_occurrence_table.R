# Declare Test - 0501 - All registry except PURCH condition occurrence mappings
declareTest(0501, "Condition Occurrence table mappings for all registries except PURCH for a specific finngenid")
# Add Finngenid_info
add_finngenid_info(finngenid="FG0501001", sex="female",
                   bl_year = as_subquery(1992),bl_age = as_subquery(46.0),
                   approx_birth_date = "1947-05-18", fu_end_age = as_subquery(74.31))
# Add HILMO registry
add_hilmo(finngenid = "FG0501001", source = "INPAT", event_age = as_subquery(47.42), approx_event_day = "1994-03-08",
          code1_icd_symptom_operation_code = "7890A", code4_hospital_days_na = "5", category = "1", index = "2")
add_hilmo(finngenid = "FG0501001", source = "OPER_IN", event_age = as_subquery(48.09), approx_event_day = "1994-11-07",
          code1_icd_symptom_operation_code = "9506", category = "MFHL1", index = "3")
add_hilmo(finngenid = "FG0501001", source = "OUTPAT", event_age = as_subquery(54.77), approx_event_day = "2001-07-15",
          code1_icd_symptom_operation_code = "F2501", code4_hospital_days_na = NULL, category = "1", index = "4")
add_hilmo(finngenid = "FG0501001", source = "OPER_OUT", event_age = as_subquery(64.53), approx_event_day = "2011-04-19",
          code1_icd_symptom_operation_code = "AN1", category = "HPN1", index = "5")
# Add REIMB registry
add_reimb(finngenid = "FG0501001", source = "REIMB", event_age = as_subquery(56.84), approx_event_day = "2003-08-10",
          code1_kela_disease = "3023", code2_icd = "J301", index = "6")
# Add PRIM_OUT registry
add_prim_out(finngenid = "FG0501001", source = "PRIM_OUT", event_age = as_subquery(64.87), approx_event_day = "2011-08-18",
             code1_code = "E117", category = "ICD1", index = "7")
# Add CANC registry
add_canc(finngenid = "FG0501001", source = "CANC", event_age = as_subquery(47.53), approx_event_day = "1994-04-21",
         code1_topo = "C619", code2_morpho = "8140", code3_beh = "3", index = "8")
# Add DEATH registry
add_death(finngenid = "FG0501001", source = "DEATH", event_age = as_subquery(74.31), approx_event_day = "2021-01-27",
          code1_cause_of_death = "I482", index = "9")
add_death(finngenid = "FG0501001", source = "DEATH", event_age = as_subquery(74.31), approx_event_day = "2021-01-27",
          code1_cause_of_death = "E112", index = "9")
add_death(finngenid = "FG0501001", source = "DEATH", event_age = as_subquery(74.31), approx_event_day = "2021-01-27",
          code1_cause_of_death = "I10", index = "9")

# Expect Condition occurrence
expect_condition_occurrence(#condition_occurrence_id  = ,
                            person_id = lookup_person("person_id", person_source_value="FG0501001"),
                            visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0501001"), visit_source_value = "SOURCE=CANC;INDEX=8"),
                            condition_concept_id = as_subquery(4161028),
                            condition_start_date = "1994-04-21", condition_start_datetime = "1994-04-21T00:00:00",
                            condition_end_date = "1994-04-21", condition_end_datetime = "1994-04-21T00:00:00",
                            condition_type_concept_id = as_subquery(32879), condition_status_concept_id = as_subquery(32902),
                            provider_id = as_subquery(0),
                            condition_source_value = "CODE1=C619;CODE2=8140;CODE3=3", condition_source_concept_id = as_subquery(44499685),
                            condition_status_source_value = NULL
)
expect_condition_occurrence(#condition_occurrence_id  = ,
                            person_id = lookup_person("person_id", person_source_value="FG0501001"),
                            visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0501001"), visit_source_value = "SOURCE=OUTPAT;CODE1=F2501;CATEGORY=1;INDEX=4"),
                            condition_concept_id = as_subquery(4153292),
                            condition_start_date = "2001-07-15", condition_start_datetime = "2001-07-15T00:00:00",
                            condition_end_date = "2001-07-15", condition_end_datetime = "2001-07-15T00:00:00",
                            condition_type_concept_id = as_subquery(32879), condition_status_concept_id = as_subquery(32908),
                            provider_id = as_subquery(0),
                            condition_source_value = "CODE1=F2501;CODE2=;CODE3=", condition_source_concept_id = as_subquery(2010001965),
                            condition_status_source_value = "1"
)
expect_condition_occurrence(#condition_occurrence_id  = ,
                            person_id = lookup_person("person_id", person_source_value="FG0501001"),
                            visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0501001"), visit_source_value = "SOURCE=REIMB;INDEX=6"),
                            condition_concept_id = as_subquery(256439),
                            condition_start_date = "2003-08-10", condition_start_datetime = "2003-08-10T00:00:00",
                            condition_end_date = "2003-08-10", condition_end_datetime = "2003-08-10T00:00:00",
                            condition_type_concept_id = as_subquery(32879), condition_status_concept_id = as_subquery(32893),
                            provider_id = as_subquery(0),
                            condition_source_value = "CODE1=J30.1;CODE2=;CODE3=", condition_source_concept_id = as_subquery(45591553),
                            condition_status_source_value = NULL
)
expect_condition_occurrence(#condition_occurrence_id  = ,
                            person_id = lookup_person("person_id", person_source_value="FG0501001"),
                            visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0501001"), visit_source_value = "SOURCE=REIMB;INDEX=6"),
                            condition_concept_id = as_subquery(0),
                            condition_start_date = "2003-08-10", condition_start_datetime = "2003-08-10T00:00:00",
                            condition_end_date = "2003-08-10", condition_end_datetime = "2003-08-10T00:00:00",
                            condition_type_concept_id = as_subquery(32879), condition_status_concept_id = as_subquery(32893),
                            provider_id = as_subquery(0),
                            condition_source_value = "CODE1=3023;CODE2=;CODE3=", condition_source_concept_id = as_subquery(2003000253),
                            condition_status_source_value = NULL
)
expect_condition_occurrence(#condition_occurrence_id  = ,
                            person_id = lookup_person("person_id", person_source_value="FG0501001"),
                            visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0501001"), visit_source_value = "SOURCE=PRIM_OUT;CODE1=E117;CATEGORY=ICD1;INDEX=7"),
                            condition_concept_id = as_subquery(443732),
                            condition_start_date = "2011-08-18", condition_start_datetime = "2011-08-18T00:00:00",
                            condition_end_date = "2011-08-18", condition_end_datetime = "2011-08-18T00:00:00",
                            condition_type_concept_id = as_subquery(32879), condition_status_concept_id = NULL,
                            provider_id = as_subquery(0),
                            condition_source_value = "CODE1=E117;CODE2=;CODE3=", condition_source_concept_id = as_subquery(45561950),
                            condition_status_source_value = "ICD1"
)
expect_condition_occurrence(#condition_occurrence_id  = ,
                            person_id = lookup_person("person_id", person_source_value="FG0501001"),
                            visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0501001"), visit_source_value = "SOURCE=DEATH;CODE1=E112;INDEX=9"),
                            condition_concept_id = as_subquery(0),
                            condition_start_date = "2021-01-27", condition_start_datetime = "2021-01-27T00:00:00",
                            condition_end_date = "2021-01-27", condition_end_datetime = "2021-01-27T00:00:00",
                            condition_type_concept_id = as_subquery(32879), condition_status_concept_id = as_subquery(32911),
                            provider_id = as_subquery(0),
                            condition_source_value = "CODE1=E112;CODE2=;CODE3=", condition_source_concept_id = as_subquery(45605400),
                            condition_status_source_value = "U"
)
expect_condition_occurrence(#condition_occurrence_id  = ,
                            person_id = lookup_person("person_id", person_source_value="FG0501001"),
                            visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0501001"), visit_source_value = "SOURCE=DEATH;CODE1=I10;INDEX=9"),
                            condition_concept_id = as_subquery(0),
                            condition_start_date = "2021-01-27", condition_start_datetime = "2021-01-27T00:00:00",
                            condition_end_date = "2021-01-27", condition_end_datetime = "2021-01-27T00:00:00",
                            condition_type_concept_id = as_subquery(32879), condition_status_concept_id = as_subquery(32911),
                            provider_id = as_subquery(0),
                            condition_source_value = "CODE1=I10;CODE2=;CODE3=", condition_source_concept_id = as_subquery(45591453),
                            condition_status_source_value = "U"
)
expect_condition_occurrence(#condition_occurrence_id  = ,
                            person_id = lookup_person("person_id", person_source_value="FG0501001"),
                            visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0501001"), visit_source_value = "SOURCE=DEATH;CODE1=I482;INDEX=9"),
                            condition_concept_id = as_subquery(0),
                            condition_start_date = "2021-01-27", condition_start_datetime = "2021-01-27T00:00:00",
                            condition_end_date = "2021-01-27", condition_end_datetime = "2021-01-27T00:00:00",
                            condition_type_concept_id = as_subquery(32879), condition_status_concept_id = as_subquery(32911),
                            provider_id = as_subquery(0),
                            condition_source_value = "CODE1=I482;CODE2=;CODE3=", condition_source_concept_id = as_subquery(45591467),
                            condition_status_source_value = "U"
)
