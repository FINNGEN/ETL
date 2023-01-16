# Declare Test - 0801 - Measurement table mappings for HILMO and PRIM_OUT registries for a specific finngenid
declareTest(0801, "Measurement table mappings for HILMO and PRIM_OUT registries for a specific finngenid")
# Add Finngenid_info
add_finngenid_info(finngenid="FG0801001", sex="female",
                   bl_year = as_subquery(2003),bl_age = as_subquery(46.0),
                   approx_birth_date = "1957-05-18", fu_end_age = as_subquery(63.05))
# Add HILMO registry
add_hilmo(finngenid = "FG0801001", source = "INPAT", event_age = as_subquery(47.42), approx_event_day = "2004-08-19",
          code1_icd_symptom_operation_code = "Z015", code4_hospital_days_na = "3", icdver = "10", category = "3", index = "801")
add_hilmo(finngenid = "FG0801001", source = "OPER_IN", event_age = as_subquery(48.09), approx_event_day = "2005-03-17",
          code1_icd_symptom_operation_code = "TFP30", category = "NOM2", index = "802")
add_hilmo(finngenid = "FG0801001", source = "OUTPAT", event_age = as_subquery(52.77), approx_event_day = "2009-12-24",
          code1_icd_symptom_operation_code = "Z363", code4_hospital_days_na = NULL, icdver = "10", category = "1", index = "803")
add_hilmo(finngenid = "FG0801001", source = "OPER_OUT", event_age = as_subquery(54.53), approx_event_day = "2011-09-09",
          code1_icd_symptom_operation_code = "XKD00", category = "NOM2", index = "804")
# Add PRIM_OUT registry
add_prim_out(finngenid = "FG0801001", source = "PRIM_OUT", event_age = as_subquery(57.87), approx_event_day = "2015-02-04",
             code1_code = "Z017", category = "ICD1", index = "805")

# Expect measurement
expect_measurement(#measurement_id = as_subquery(1),
                   person_id = lookup_person("person_id", person_source_value = "FG0801001"),
                   visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0801001"), visit_source_value = "SOURCE=INPAT;CODE1=Z015;CATEGORY=3;INDEX=801"),
                   measurement_concept_id = as_subquery(4092969),
                   measurement_date = "2004-08-19", measurement_datetime = "2004-08-19T00:00:00", measurement_time = "00:00:00",
                   measurement_type_concept_id = as_subquery(32879),
                   operator_concept_id = NULL, value_as_number = NULL, value_as_concept_id = NULL,
                   unit_concept_id = NULL, range_low = NULL, range_high = NULL, provider_id = as_subquery(0),
                   measurement_source_value = "Z015", measurement_source_concept_id = as_subquery(45590690),
                   unit_source_value = NULL, unit_source_concept_id = NULL,
                   value_source_value = NULL,
                   measurement_event_id = NULL, meas_event_field_concept_id = NULL
)
expect_measurement(#measurement_id = as_subquery(2),
                   person_id = lookup_person("person_id", person_source_value = "FG0801001"),
                   visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0801001"), visit_source_value = "SOURCE=OPER_IN;CODE1=TFP30;CATEGORY=NOM2;INDEX=802"),
                   measurement_concept_id = as_subquery(3010322),
                   measurement_date = "2005-03-17", measurement_datetime = "2005-03-17T00:00:00", measurement_time = "00:00:00",
                   measurement_type_concept_id = as_subquery(32879),
                   operator_concept_id = NULL, value_as_number = NULL, value_as_concept_id = NULL,
                   unit_concept_id = NULL, range_low = NULL, range_high = NULL, provider_id = as_subquery(0),
                   measurement_source_value = "TFP30", measurement_source_concept_id = as_subquery(2011003225),
                   unit_source_value = NULL, unit_source_concept_id = NULL,
                   value_source_value = NULL,
                   measurement_event_id = NULL, meas_event_field_concept_id = NULL
)
expect_measurement(#measurement_id = as_subquery(3),
                   person_id = lookup_person("person_id", person_source_value = "FG0801001"),
                   visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0801001"), visit_source_value = "SOURCE=OUTPAT;CODE1=Z363;CATEGORY=1;INDEX=803"),
                   measurement_concept_id = as_subquery(36713462),
                   measurement_date = "2009-12-24", measurement_datetime = "2009-12-24T00:00:00", measurement_time = "00:00:00",
                   measurement_type_concept_id = as_subquery(32879),
                   operator_concept_id = NULL, value_as_number = NULL, value_as_concept_id = NULL,
                   unit_concept_id = NULL, range_low = NULL, range_high = NULL, provider_id = as_subquery(0),
                   measurement_source_value = "Z363", measurement_source_concept_id = as_subquery(45581023),
                   unit_source_value = NULL, unit_source_concept_id = NULL,
                   value_source_value = NULL,
                   measurement_event_id = NULL, meas_event_field_concept_id = NULL
)
expect_measurement(#measurement_id = as_subquery(4),
                   person_id = lookup_person("person_id", person_source_value = "FG0801001"),
                   visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0801001"), visit_source_value = "SOURCE=OPER_OUT;CODE1=XKD00;CATEGORY=NOM2;INDEX=804"),
                   measurement_concept_id = as_subquery(4261340),
                   measurement_date = "2011-09-09", measurement_datetime = "2011-09-09T00:00:00", measurement_time = "00:00:00",
                   measurement_type_concept_id = as_subquery(32879),
                   operator_concept_id = NULL, value_as_number = NULL, value_as_concept_id = NULL,
                   unit_concept_id = NULL, range_low = NULL, range_high = NULL, provider_id = as_subquery(0),
                   measurement_source_value = "XKD00", measurement_source_concept_id = as_subquery(2011006096),
                   unit_source_value = NULL, unit_source_concept_id = NULL,
                   value_source_value = NULL,
                   measurement_event_id = NULL, meas_event_field_concept_id = NULL
)
expect_measurement(#measurement_id = as_subquery(5),
                   person_id = lookup_person("person_id", person_source_value = "FG0801001"),
                   visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0801001"), visit_source_value = "SOURCE=PRIM_OUT;CODE1=Z017;CATEGORY=ICD1;INDEX=805"),
                   measurement_concept_id = as_subquery(4034850),
                   measurement_date = "2015-02-04", measurement_datetime = "2015-02-04T00:00:00", measurement_time = "00:00:00",
                   measurement_type_concept_id = as_subquery(32879),
                   operator_concept_id = NULL, value_as_number = NULL, value_as_concept_id = NULL,
                   unit_concept_id = NULL, range_low = NULL, range_high = NULL, provider_id = as_subquery(0),
                   measurement_source_value = "Z017", measurement_source_concept_id = as_subquery(45556809),
                   unit_source_value = NULL, unit_source_concept_id = NULL,
                   value_source_value = NULL,
                   measurement_event_id = NULL, meas_event_field_concept_id = NULL
)

