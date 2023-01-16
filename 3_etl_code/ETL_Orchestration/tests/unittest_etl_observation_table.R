# Declare Test - 1001 - Observation table mappings for HILMO and PRIM_OUT registries for a specific finngenid
declareTest(1001, "Observation table mappings for HILMO and PRIM_OUT registries for a specific finngenid")
# Add Finngenid_info
add_finngenid_info(finngenid="FG1001001", sex="female",
                   bl_year = as_subquery(2007),bl_age = as_subquery(56.0),
                   approx_birth_date = "1951-03-22", fu_end_age = as_subquery(71.56))
# Add HILMO registry
add_hilmo(finngenid = "FG1001001", source = "INPAT", event_age = as_subquery(57.42), approx_event_day = "2008-04-02",
          code1_icd_symptom_operation_code = "X58", code4_hospital_days_na = "15", icdver = "10", category = "EX1", index = "1001")
add_hilmo(finngenid = "FG1001001", source = "OPER_IN", event_age = as_subquery(60.09), approx_event_day = "2011-01-09",
          code1_icd_symptom_operation_code = "ZXE10", category = "NOM1", index = "1002")
add_hilmo(finngenid = "FG1001001", source = "OUTPAT", event_age = as_subquery(62.77), approx_event_day = "2013-07-07",
          code1_icd_symptom_operation_code = "W00", code4_hospital_days_na = NULL, icdver = "10", category = "EX2", index = "1003")
add_hilmo(finngenid = "FG1001001", source = "OPER_OUT", event_age = as_subquery(66.53), approx_event_day = "2017-05-13",
          code1_icd_symptom_operation_code = "WZB00", category = "NOM1", index = "1004")
# Add PRIM_OUT registry
add_prim_out(finngenid = "FG1001001", source = "PRIM_OUT", event_age = as_subquery(69.87), approx_event_day = "2020-11-17",
             code1_code = "V19", category = "ICD1", index = "1005")

# Expect observation
expect_observation(#observation_id = as_subquery(1),
                   person_id = lookup_person("person_id", person_source_value = "FG1001001"),
                   visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG1001001"), visit_source_value = "SOURCE=INPAT;CODE1=X58;CATEGORY=EX1;INDEX=1001"),
                   observation_concept_id = as_subquery(4305831),
                   observation_date = "2008-04-02", observation_datetime = "2008-04-02T00:00:00",
                   observation_type_concept_id = as_subquery(32879),
                   value_as_number = NULL, value_as_string = NULL, value_as_concept_id = NULL, qualifier_concept_id = NULL,
                   unit_concept_id = NULL, provider_id = as_subquery(0),
                   observation_source_value = "X58", observation_source_concept_id = as_subquery(45756411),
                   unit_source_value = NULL, qualifier_source_value = NULL, value_source_value = NULL,
                   observation_event_id = NULL, obs_event_field_concept_id = NULL
)
expect_observation(#observation_id = as_subquery(2),
                   person_id = lookup_person("person_id", person_source_value = "FG1001001"),
                   visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG1001001"), visit_source_value = "SOURCE=OPER_IN;CODE1=ZXE10;CATEGORY=NOM1;INDEX=1002"),
                   observation_concept_id = as_subquery(1175267),
                   observation_date = "2011-01-09", observation_datetime = "2011-01-09T00:00:00",
                   observation_type_concept_id = as_subquery(32879),
                   value_as_number = NULL, value_as_string = NULL, value_as_concept_id = NULL, qualifier_concept_id = NULL,
                   unit_concept_id = NULL, provider_id = as_subquery(0),
                   observation_source_value = "ZXE10", observation_source_concept_id = as_subquery(2011011401),
                   unit_source_value = NULL, qualifier_source_value = NULL, value_source_value = NULL,
                   observation_event_id = NULL, obs_event_field_concept_id = NULL
)
expect_observation(#observation_id = as_subquery(3),
                   person_id = lookup_person("person_id", person_source_value = "FG1001001"),
                   visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG1001001"), visit_source_value = "SOURCE=OUTPAT;CODE1=W00;CATEGORY=EX2;INDEX=1003"),
                   observation_concept_id = as_subquery(4053863),
                   observation_date = "2013-07-07", observation_datetime = "2013-07-07T00:00:00",
                   observation_type_concept_id = as_subquery(32879),
                   value_as_number = NULL, value_as_string = NULL, value_as_concept_id = NULL, qualifier_concept_id = NULL,
                   unit_concept_id = NULL, provider_id = as_subquery(0),
                   observation_source_value = "W00", observation_source_concept_id = as_subquery(45756242),
                   unit_source_value = NULL, qualifier_source_value = NULL, value_source_value = NULL,
                   observation_event_id = NULL, obs_event_field_concept_id = NULL
)
expect_observation(#observation_id = as_subquery(4),
                   person_id = lookup_person("person_id", person_source_value = "FG1001001"),
                   visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG1001001"), visit_source_value = "SOURCE=OPER_OUT;CODE1=WZB00;CATEGORY=NOM1;INDEX=1004"),
                   observation_concept_id = as_subquery(4190892),
                   observation_date = "2017-05-13", observation_datetime = "2017-05-13T00:00:00",
                   observation_type_concept_id = as_subquery(32879),
                   value_as_number = NULL, value_as_string = NULL, value_as_concept_id = NULL, qualifier_concept_id = NULL,
                   unit_concept_id = NULL, provider_id = as_subquery(0),
                   observation_source_value = "WZB00", observation_source_concept_id = as_subquery(2011010884),
                   unit_source_value = NULL, qualifier_source_value = NULL, value_source_value = NULL,
                   observation_event_id = NULL, obs_event_field_concept_id = NULL
)
expect_observation(#observation_id = as_subquery(5),
                   person_id = lookup_person("person_id", person_source_value = "FG1001001"),
                   visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG1001001"), visit_source_value = "SOURCE=OPER_OUT;CODE1=WZB00;CATEGORY=NOM1;INDEX=1004"),
                   observation_concept_id = as_subquery(4197458),
                   observation_date = "2017-05-13", observation_datetime = "2017-05-13T00:00:00",
                   observation_type_concept_id = as_subquery(32879),
                   value_as_number = NULL, value_as_string = NULL, value_as_concept_id = NULL, qualifier_concept_id = NULL,
                   unit_concept_id = NULL, provider_id = as_subquery(0),
                   observation_source_value = "WZB00", observation_source_concept_id = as_subquery(2011010884),
                   unit_source_value = NULL, qualifier_source_value = NULL, value_source_value = NULL,
                   observation_event_id = NULL, obs_event_field_concept_id = NULL
)
expect_observation(#observation_id = as_subquery(6),
                   person_id = lookup_person("person_id", person_source_value = "FG1001001"),
                   visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG1001001"), visit_source_value = "SOURCE=PRIM_OUT;CODE1=V19;CATEGORY=ICD1;INDEX=1005"),
                   observation_concept_id = as_subquery(443423),
                   observation_date = "2020-11-17", observation_datetime = "2020-11-17T00:00:00",
                   observation_type_concept_id = as_subquery(32879),
                   value_as_number = NULL, value_as_string = NULL, value_as_concept_id = NULL, qualifier_concept_id = NULL,
                   unit_concept_id = NULL, provider_id = as_subquery(0),
                   observation_source_value = "V19", observation_source_concept_id = as_subquery(45756225),
                   unit_source_value = NULL, qualifier_source_value = NULL, value_source_value = NULL,
                   observation_event_id = NULL, obs_event_field_concept_id = NULL
)

