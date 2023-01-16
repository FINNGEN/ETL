# Declare Test - 0901 - Device Exposure table mappings for HILMO and PRIM_OUT registries for a specific finngenid
declareTest(0901, "Device Exposure table mappings for HILMO and PRIM_OUT registries for a specific finngenid")
# Add Finngenid_info
add_finngenid_info(finngenid="FG0901001", sex="female",
                   bl_year = as_subquery(1999),bl_age = as_subquery(43.0),
                   approx_birth_date = "1956-05-12", fu_end_age = as_subquery(66.06))
# Add HILMO registry
add_hilmo(finngenid = "FG0901001", source = "OPER_IN", event_age = as_subquery(48.29), approx_event_day = "2004-04-25",
          code1_icd_symptom_operation_code = "TNX32", category = "NOM4", index = "901")
add_hilmo(finngenid = "FG0901001", source = "OPER_OUT", event_age = as_subquery(51.34), approx_event_day = "2007-08-03",
          code1_icd_symptom_operation_code = "ZX121", category = "NOM1", index = "902")
# Add PRIM_OUT registry
add_prim_out(finngenid = "FG0901001", source = "PRIM_OUT", event_age = as_subquery(61.47), approx_event_day = "2017-03-18",
             code1_code = "SPC01", category = "MOP1", index = "903")

# Expect device exposure
expect_device_exposure(#device_exposure_id = as_subquery(1),
                       person_id = lookup_person("person_id", person_source_value = "FG0901001"),
                       visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0901001"), visit_source_value = "SOURCE=OPER_IN;CODE1=TNX32;CATEGORY=NOM4;INDEX=901"),
                       device_concept_id = as_subquery(4042424),
                       device_exposure_start_date = "2004-04-25", device_exposure_start_datetime = "2004-04-25T00:00:00",
                       device_exposure_end_date = "2004-04-25", device_exposure_end_datetime = "2004-04-25T00:00:00",
                       device_type_concept_id = as_subquery(32879),
                       unique_device_id = NULL, production_id = NULL, quantity = as_subquery(0), provider_id = as_subquery(0),
                       device_source_value = "TNX32", device_source_concept_id = as_subquery(2011008563),
                       unit_concept_id = NULL, unit_source_value = NULL, unit_source_concept_id = NULL
)
expect_device_exposure(#device_exposure_id = as_subquery(2),
                       person_id = lookup_person("person_id", person_source_value = "FG0901001"),
                       visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0901001"), visit_source_value = "SOURCE=OPER_OUT;CODE1=ZX121;CATEGORY=NOM1;INDEX=902"),
                       device_concept_id = as_subquery(4179206),
                       device_exposure_start_date = "2007-08-03", device_exposure_start_datetime = "2007-08-03T00:00:00",
                       device_exposure_end_date = "2007-08-03", device_exposure_end_datetime = "2007-08-03T00:00:00",
                       device_type_concept_id = as_subquery(32879),
                       unique_device_id = NULL, production_id = NULL, quantity = as_subquery(0), provider_id = as_subquery(0),
                       device_source_value = "ZX121", device_source_concept_id = as_subquery(2011011496),
                       unit_concept_id = NULL, unit_source_value = NULL, unit_source_concept_id = NULL
)
expect_device_exposure(#device_exposure_id = as_subquery(3),
                       person_id = lookup_person("person_id", person_source_value = "FG0901001"),
                       visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0901001"), visit_source_value = "SOURCE=PRIM_OUT;CODE1=SPC01;CATEGORY=MOP1;INDEX=903"),
                       device_concept_id = as_subquery(4213730),
                       device_exposure_start_date = "2017-03-18", device_exposure_start_datetime = "2017-03-18T00:00:00",
                       device_exposure_end_date = "2017-03-18", device_exposure_end_datetime = "2017-03-18T00:00:00",
                       device_type_concept_id = as_subquery(32879),
                       unique_device_id = NULL, production_id = NULL, quantity = as_subquery(0), provider_id = as_subquery(0),
                       device_source_value = "SPC01", device_source_concept_id = as_subquery(2011010505),
                       unit_concept_id = NULL, unit_source_value = NULL, unit_source_concept_id = NULL
)

