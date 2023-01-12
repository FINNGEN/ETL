

# Declare Test - 0301 - All registry visit occurrence mappings
declareTest(0301, "Visit Occurrence table mappings for all registries for a specific finngenid")
# Add Finngenid_info
add_finngenid_info(finngenid="FG0301001", sex="female",
                   bl_year = as_subquery(1992),bl_age = as_subquery(46.0),
                   approx_birth_date = "1947-05-18", fu_end_age = as_subquery(74.31))
# Add PURCH registry
add_purch(finngenid = "FG0301001", source = "PURCH", event_age = as_subquery(47.26), approx_event_day = "1994-01-08",
          code1_atc_code = "N02BE01", code3_vnro = "169275", code4_plkm = "1", index = "1")
# Add HILMO registry
add_hilmo(finngenid = "FG0301001", source = "INPAT", event_age = as_subquery(47.42), approx_event_day = "1994-03-08",
          code1_icd_symptom_operation_code = "7890A", code4_hospital_days_na = "5", category = "1", index = "2")
add_hilmo(finngenid = "FG0301001", source = "OPER_IN", event_age = as_subquery(48.09), approx_event_day = "1994-11-07",
          code1_icd_symptom_operation_code = "9506", category = "MFHL1", index = "3")
add_hilmo(finngenid = "FG0301001", source = "OUTPAT", event_age = as_subquery(54.77), approx_event_day = "2001-07-15",
          code1_icd_symptom_operation_code = "F2501", code4_hospital_days_na = NULL, category = "1", index = "4")
add_hilmo(finngenid = "FG0301001", source = "OPER_OUT", event_age = as_subquery(64.53), approx_event_day = "2011-04-19",
          code1_icd_symptom_operation_code = "AN1", category = "HPN1", index = "5")
# Add REIMB registry
add_reimb(finngenid = "FG0301001", source = "REIMB", event_age = as_subquery(56.84), approx_event_day = "2003-08-10",
          code1_kela_disease = "3023", code2_icd = "J301", index = "6")
# Add PRIM_OUT registry
add_prim_out(finngenid = "FG0301001", source = "PRIM_OUT", event_age = as_subquery(64.87), approx_event_day = "2011-08-18",
             code1_code = "SGB10", category = "MOP1", index = "7")
# Add CANC registry
add_canc(finngenid = "FG0301001", source = "CANC", event_age = as_subquery(47.53), approx_event_day = "1994-04-21",
         code1_topo = "C619", code2_morpho = "8140", code3_beh = "3", index = "8")
# Add DEATH registry
add_death(finngenid = "FG0301001", source = "DEATH", event_age = as_subquery(74.31), approx_event_day = "2021-01-27",
          code1_cause_of_death = "I482", index = "9")
add_death(finngenid = "FG0301001", source = "DEATH", event_age = as_subquery(74.31), approx_event_day = "2021-01-27",
          code1_cause_of_death = "E112", index = "9")
add_death(finngenid = "FG0301001", source = "DEATH", event_age = as_subquery(74.31), approx_event_day = "2021-01-27",
          code1_cause_of_death = "I10", index = "9")

# Expect the visit occurrence
expect_visit_occurrence(person_id = lookup_person("person_id", person_source_value="FG0301001"),visit_occurrence_id = as_subquery(1),
                        visit_start_date = "1994-01-08", visit_start_datetime = "1994-01-08T00:00:00",
                        visit_end_date = "1994-01-08", visit_end_datetime = "1994-01-08T00:00:00",
                        visit_concept_id = as_subquery(581458),#visit_source_value = "PURCH",
                        visit_type_concept_id = as_subquery(32879),
                        provider_id = as_subquery(0), care_site_id = as_subquery(0),
                        visit_source_value = "SOURCE=PURCH;INDEX=1",
                        visit_source_concept_id = as_subquery(0), admitted_from_concept_id = as_subquery(0),
                        admitted_from_source_value = NULL, discharged_to_concept_id = as_subquery(0),
                        discharged_to_source_value = NULL, preceding_visit_occurrence_id = as_subquery(0)
)
expect_visit_occurrence(person_id = lookup_person("person_id", person_source_value="FG0301001"), visit_occurrence_id = as_subquery(2),
                        visit_start_date = "1994-03-08", visit_start_datetime = "1994-03-08T00:00:00",
                        visit_end_date = "1994-03-13", visit_end_datetime = "1994-03-13T00:00:00",
                        visit_concept_id = as_subquery(4000000003),#visit_source_value = "INPAT",
                        visit_type_concept_id = as_subquery(32879),
                        provider_id = as_subquery(0), care_site_id = as_subquery(0),
                        visit_source_value = "SOURCE=INPAT;CODE1=7890A;CATEGORY=1;INDEX=2",
                        visit_source_concept_id = as_subquery(0), admitted_from_concept_id = as_subquery(0),
                        admitted_from_source_value = NULL, discharged_to_concept_id = as_subquery(0),
                        discharged_to_source_value = NULL, preceding_visit_occurrence_id = as_subquery(0)
)
expect_visit_occurrence(person_id = lookup_person("person_id", person_source_value="FG0301001"), visit_occurrence_id = as_subquery(3),
                        visit_start_date = "1994-04-21", visit_start_datetime = "1994-04-21T00:00:00",
                        visit_end_date = "1994-04-21", visit_end_datetime = "1994-04-21T00:00:00",
                        visit_concept_id = as_subquery(4000000006),#visit_source_value = "CANC",
                        visit_type_concept_id = as_subquery(32879),
                        provider_id = as_subquery(0), care_site_id = as_subquery(0),
                        visit_source_value = "SOURCE=CANC;INDEX=8",
                        visit_source_concept_id = as_subquery(0), admitted_from_concept_id = as_subquery(0),
                        admitted_from_source_value = NULL, discharged_to_concept_id = as_subquery(0),
                        discharged_to_source_value = NULL, preceding_visit_occurrence_id = as_subquery(0)
)
expect_visit_occurrence(person_id = lookup_person("person_id", person_source_value="FG0301001"),visit_occurrence_id = as_subquery(4),
                        visit_start_date = "1994-11-07", visit_start_datetime = "1994-11-07T00:00:00",
                        visit_end_date = "1994-11-07", visit_end_datetime = "1994-11-07T00:00:00",
                        visit_concept_id = as_subquery(4000000003),#visit_source_value = "OPER_IN",
                        visit_type_concept_id = as_subquery(32879),
                        provider_id = as_subquery(0), care_site_id = as_subquery(0),
                        visit_source_value = "SOURCE=OPER_IN;CODE1=9506;CATEGORY=MFHL1;INDEX=3",
                        visit_source_concept_id = as_subquery(0), admitted_from_concept_id = as_subquery(0),
                        admitted_from_source_value = NULL, discharged_to_concept_id = as_subquery(0),
                        discharged_to_source_value = NULL, preceding_visit_occurrence_id = as_subquery(0)
)
expect_visit_occurrence(person_id = lookup_person("person_id", person_source_value="FG0301001"),visit_occurrence_id = as_subquery(5),
                        visit_start_date = "2001-07-15", visit_start_datetime = "2001-07-15T00:00:00",
                        visit_end_date = "2001-07-15", visit_end_datetime = "2001-07-15T00:00:00",
                        visit_concept_id = as_subquery(4000000004),#visit_source_value = "OUTPAT",
                        visit_type_concept_id = as_subquery(32879),
                        provider_id = as_subquery(0), care_site_id = as_subquery(0),
                        visit_source_value = "SOURCE=OUTPAT;CODE1=F2501;CATEGORY=1;INDEX=4",
                        visit_source_concept_id = as_subquery(0), admitted_from_concept_id = as_subquery(0),
                        admitted_from_source_value = NULL, discharged_to_concept_id = as_subquery(0),
                        discharged_to_source_value = NULL, preceding_visit_occurrence_id = as_subquery(0)
)
expect_visit_occurrence(person_id = lookup_person("person_id", person_source_value="FG0301001"),visit_occurrence_id = as_subquery(6),
                        visit_start_date = "2003-08-10", visit_start_datetime = "2003-08-10T00:00:00",
                        visit_end_date = "2003-08-10", visit_end_datetime = "2003-08-10T00:00:00",
                        visit_concept_id = as_subquery(38004193),#visit_source_value = "REIMB",
                        visit_type_concept_id = as_subquery(32879),
                        provider_id = as_subquery(0), care_site_id = as_subquery(0),
                        visit_source_value = "SOURCE=REIMB;INDEX=6",
                        visit_source_concept_id = as_subquery(0), admitted_from_concept_id = as_subquery(0),
                        admitted_from_source_value = NULL, discharged_to_concept_id = as_subquery(0),
                        discharged_to_source_value = NULL, preceding_visit_occurrence_id = as_subquery(0)
)
expect_visit_occurrence(person_id = lookup_person("person_id", person_source_value="FG0301001"),visit_occurrence_id = as_subquery(7),
                        visit_start_date = "2011-04-19", visit_start_datetime = "2011-04-19T00:00:00",
                        visit_end_date = "2011-04-19", visit_end_datetime = "2011-04-19T00:00:00",
                        visit_concept_id = as_subquery(4000000004),#visit_source_value = "OPER_OUT",
                        visit_type_concept_id = as_subquery(32879),
                        provider_id = as_subquery(0), care_site_id = as_subquery(0),
                        visit_source_value = "SOURCE=OPER_OUT;CODE1=AN1;CATEGORY=HPN1;INDEX=5",
                        visit_source_concept_id = as_subquery(0), admitted_from_concept_id = as_subquery(0),
                        admitted_from_source_value = NULL, discharged_to_concept_id = as_subquery(0),
                        discharged_to_source_value = NULL, preceding_visit_occurrence_id = as_subquery(0)
)
expect_visit_occurrence(person_id = lookup_person("person_id", person_source_value="FG0301001"),visit_occurrence_id = as_subquery(8),
                        visit_start_date = "2011-08-18", visit_start_datetime = "2011-08-18T00:00:00",
                        visit_end_date = "2011-08-18", visit_end_datetime = "2011-08-18T00:00:00",
                        visit_concept_id = as_subquery(4000000008),#visit_source_value = "PRIM_OUT",
                        visit_type_concept_id = as_subquery(32879),
                        provider_id = as_subquery(0), care_site_id = as_subquery(0),
                        visit_source_value = "SOURCE=PRIM_OUT;CODE1=SGB10;CATEGORY=MOP1;INDEX=7",
                        visit_source_concept_id = as_subquery(0), admitted_from_concept_id = as_subquery(0),
                        admitted_from_source_value = NULL, discharged_to_concept_id = as_subquery(0),
                        discharged_to_source_value = NULL, preceding_visit_occurrence_id = as_subquery(0)
)
expect_visit_occurrence(person_id = lookup_person("person_id", person_source_value="FG0301001"),#visit_occurrence_id = as_subquery(9),
                        visit_start_date = "2021-01-27", visit_start_datetime = "2021-01-27T00:00:00",
                        visit_end_date = "2021-01-27", visit_end_datetime = "2021-01-27T00:00:00",
                        visit_concept_id = as_subquery(0),#visit_source_value = "DEATH",
                        visit_type_concept_id = as_subquery(32879),
                        provider_id = as_subquery(0), care_site_id = as_subquery(0),
                        visit_source_value = "SOURCE=DEATH;CODE1=E112;INDEX=9",
                        visit_source_concept_id = as_subquery(0), admitted_from_concept_id = as_subquery(0),
                        admitted_from_source_value = NULL, discharged_to_concept_id = as_subquery(0),
                        discharged_to_source_value = NULL, preceding_visit_occurrence_id = as_subquery(0)
)
expect_visit_occurrence(person_id = lookup_person("person_id", person_source_value="FG0301001"),#visit_occurrence_id = as_subquery(10),
                        visit_start_date = "2021-01-27", visit_start_datetime = "2021-01-27T00:00:00",
                        visit_end_date = "2021-01-27", visit_end_datetime = "2021-01-27T00:00:00",
                        visit_concept_id = as_subquery(0),#visit_source_value = "DEATH",
                        visit_type_concept_id = as_subquery(32879),
                        provider_id = as_subquery(0), care_site_id = as_subquery(0),
                        visit_source_value = "SOURCE=DEATH;CODE1=I482;INDEX=9",
                        visit_source_concept_id = as_subquery(0), admitted_from_concept_id = as_subquery(0),
                        admitted_from_source_value = NULL, discharged_to_concept_id = as_subquery(0),
                        discharged_to_source_value = NULL, preceding_visit_occurrence_id = as_subquery(0)
)
expect_visit_occurrence(person_id = lookup_person("person_id", person_source_value="FG0301001"),#visit_occurrence_id = as_subquery(11),
                        visit_start_date = "2021-01-27", visit_start_datetime = "2021-01-27T00:00:00",
                        visit_end_date = "2021-01-27", visit_end_datetime = "2021-01-27T00:00:00",
                        visit_concept_id = as_subquery(0),#visit_source_value = "DEATH",
                        visit_type_concept_id = as_subquery(32879),
                        provider_id = as_subquery(0), care_site_id = as_subquery(0),
                        visit_source_value = "SOURCE=DEATH;CODE1=I10;INDEX=9",
                        visit_source_concept_id = as_subquery(0), admitted_from_concept_id = as_subquery(0),
                        admitted_from_source_value = NULL, discharged_to_concept_id = as_subquery(0),
                        discharged_to_source_value = NULL, preceding_visit_occurrence_id = as_subquery(0)
)

