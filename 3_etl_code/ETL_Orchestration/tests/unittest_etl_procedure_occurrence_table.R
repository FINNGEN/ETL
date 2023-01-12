# Declare Test - 0601 - Procedure Occurrence table mappings for HILMO and PRIM_OUT for a specific finngenid
declareTest(0601, "Procedure Occurrence table mappings for all registries except PURCH for a specific finngenid")
# Add Finngenid_info
add_finngenid_info(finngenid="FG0601001", sex="female",
                   bl_year = as_subquery(1992),bl_age = as_subquery(46.0),
                   approx_birth_date = "1946-05-18", fu_end_age = as_subquery(74.31))
# Add HILMO registry
add_hilmo(finngenid = "FG0601001", source = "INPAT", event_age = as_subquery(47.42), approx_event_day = "1994-03-08",
          code1_icd_symptom_operation_code = "O8210", code4_hospital_days_na = "4", icdver = "10", category = "1", index = "601")
add_hilmo(finngenid = "FG0601001", source = "OPER_IN", event_age = as_subquery(48.09), approx_event_day = "1994-11-07",
          code1_icd_symptom_operation_code = "DHB20", category = "NOM4", index = "602")
add_hilmo(finngenid = "FG0601001", source = "OUTPAT", event_age = as_subquery(54.77), approx_event_day = "2001-07-15",
          code1_icd_symptom_operation_code = "Z018", code4_hospital_days_na = NULL, icdver = "10", category = "1", index = "603")
add_hilmo(finngenid = "FG0601001", source = "OPER_OUT", event_age = as_subquery(65.53), approx_event_day = "2011-04-19",
          code1_icd_symptom_operation_code = "UDQ12", category = "NOM1", index = "604")
# Add PRIM_OUT registry
add_prim_out(finngenid = "FG0601001", source = "PRIM_OUT", event_age = as_subquery(65.87), approx_event_day = "2011-08-18",
             code1_code = "SGB10", category = "MOP1", index = "605")

# Expect procedure occurrence
expect_procedure_occurrence(#procedure_occurrence_id = as_subquery(1),
                            person_id = lookup_person("person_id", person_source_value="FG0601001"),
                            visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0601001"), visit_source_value = "SOURCE=INPAT;CODE1=O8210;CATEGORY=1;INDEX=601"),
                            procedure_concept_id = as_subquery(4167089),
                            procedure_date = "1994-03-08", procedure_datetime = "1994-03-08T00:00:00",
                            procedure_end_date = "1994-03-08", procedure_end_datetime = "1994-03-08T00:00:00",
                            procedure_type_concept_id = as_subquery(32879), modifier_concept_id = NULL,
                            quantity = as_subquery(1), provider_id = as_subquery(0),
                            procedure_source_value = "O8210", procedure_source_concept_id = as_subquery(2010003217),
                            modifier_source_value = NULL
)
expect_procedure_occurrence(#procedure_occurrence_id = as_subquery(2) ,
                            person_id = lookup_person("person_id", person_source_value="FG0601001"),
                            visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0601001"), visit_source_value = "SOURCE=OPER_IN;CODE1=DHB20;CATEGORY=NOM4;INDEX=602"),
                            procedure_concept_id = as_subquery(4067379),
                            procedure_date = "1994-11-07", procedure_datetime = "1994-11-07T00:00:00",
                            procedure_end_date = "1994-11-07", procedure_end_datetime = "1994-11-07T00:00:00",
                            procedure_type_concept_id = as_subquery(32879), modifier_concept_id = NULL,
                            quantity = as_subquery(1), provider_id = as_subquery(0),
                            procedure_source_value = "DHB20", procedure_source_concept_id = as_subquery(2011001689),
                            modifier_source_value = NULL
)
expect_procedure_occurrence(#procedure_occurrence_id = as_subquery(3),
                            person_id = lookup_person("person_id", person_source_value="FG0601001"),
                            visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0601001"), visit_source_value = "SOURCE=OUTPAT;CODE1=Z018;CATEGORY=1;INDEX=603"),
                            procedure_concept_id = as_subquery(4194672),
                            procedure_date = "2001-07-15", procedure_datetime = "2001-07-15T00:00:00",
                            procedure_end_date = "2001-07-15", procedure_end_datetime = "2001-07-15T00:00:00",
                            procedure_type_concept_id = as_subquery(32879), modifier_concept_id = NULL,
                            quantity = as_subquery(1), provider_id = as_subquery(0),
                            procedure_source_value = "Z018", procedure_source_concept_id = as_subquery(45581003),
                            modifier_source_value = NULL
)
expect_procedure_occurrence(#procedure_occurrence_id = as_subquery(4) ,
                            person_id = lookup_person("person_id", person_source_value="FG0601001"),
                            visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0601001"), visit_source_value = "SOURCE=OPER_OUT;CODE1=UDQ12;CATEGORY=NOM1;INDEX=604"),
                            procedure_concept_id = as_subquery(4176717),
                            procedure_date = "2011-04-19", procedure_datetime = "2011-04-19T00:00:00",
                            procedure_end_date = "2011-04-19", procedure_end_datetime = "2011-04-19T00:00:00",
                            procedure_type_concept_id = as_subquery(32879), modifier_concept_id = NULL,
                            quantity = as_subquery(1), provider_id = as_subquery(0),
                            procedure_source_value = "UDQ12", procedure_source_concept_id = as_subquery(2011001827),
                            modifier_source_value = NULL
)
expect_procedure_occurrence(#procedure_occurrence_id = as_subquery(5) ,
                            person_id = lookup_person("person_id", person_source_value="FG0601001"),
                            visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",person_id = lookup_person("person_id",person_source_value = "FG0601001"), visit_source_value = "SOURCE=PRIM_OUT;CODE1=SGB10;CATEGORY=MOP1;INDEX=605"),
                            procedure_concept_id = as_subquery(4122464),
                            procedure_date = "2011-08-18", procedure_datetime = "2011-08-18T00:00:00",
                            procedure_end_date = "2011-08-18", procedure_end_datetime = "2011-08-18T00:00:00",
                            procedure_type_concept_id = as_subquery(32879), modifier_concept_id = NULL,
                            quantity = as_subquery(1), provider_id = as_subquery(0),
                            procedure_source_value = "SGB10", procedure_source_concept_id = as_subquery(2011010388),
                            modifier_source_value = NULL
)

