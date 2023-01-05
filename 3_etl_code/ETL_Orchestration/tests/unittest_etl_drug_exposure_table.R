






# Add PURCH registry
add_purch(finngenid = "FG00000007", source = "PURCH",event_age = as_subquery(56.0), approx_event_day = "2010-03-31",
          code1_atc_code = "S01ED51", code3_vnro = "068220" )
add_purch(finngenid = "FG00000007", source = "PURCH", event_age = as_subquery(57.3), approx_event_day = "2011-06-01",
          code1_atc_code = "J01CR02", code3_vnro = "1154", code4_plkm = "2" )
add_purch(finngenid = "FG00000200", source = "PURCH", event_age = as_subquery(41.2), approx_event_day = "2019-01-01",
          code1_atc_code = "J02AC02", code3_vnro = "152991", code4_plkm = "2" )
add_purch(finngenid = "FG00000200", source = "PURCH", event_age = as_subquery(41.2), approx_event_day = "2020-10-01",
          code3_vnro = "144493" )



# Declare Tests
declareTest(101, "Drug Exposure mappings")
# Expect the drug exposure - For Finngenid FG00000007
expect_drug_exposure(drug_exposure_id = as_subquery(1), person_id = as_subquery(1), visit_occurrence_id = as_subquery(1),
                     drug_concept_id = as_subquery(904525), quantity = as_subquery(9.0),
                     drug_source_concept_id = as_subquery(2030000182), drug_source_value = "068220",
                     days_supply = as_subquery(1))
expect_drug_exposure(drug_exposure_id = as_subquery(2), person_id = as_subquery(1), visit_occurrence_id = as_subquery(1),
                     drug_concept_id = as_subquery(902427), quantity = as_subquery(9.0),
                     drug_source_concept_id = as_subquery(2030000182), drug_source_value = "068220",
                     days_supply = as_subquery(1))
expect_drug_exposure(drug_exposure_id = as_subquery(3), person_id = as_subquery(1), visit_occurrence_id = as_subquery(2),
                     drug_concept_id = as_subquery(1713332), quantity = as_subquery(24.0),
                     drug_source_concept_id = as_subquery(2030000049), drug_source_value = "001154",
                     days_supply = as_subquery(1))
expect_drug_exposure(drug_exposure_id = as_subquery(4), person_id = as_subquery(1), visit_occurrence_id = as_subquery(2),
                     drug_concept_id = as_subquery(1759842), quantity = as_subquery(24.0),
                     drug_source_concept_id = as_subquery(2030000049), drug_source_value = "001154",
                     days_supply = as_subquery(1))

# Expect the drug exposure - For Finngenid FG00000200
expect_drug_exposure(drug_exposure_id = as_subquery(1), person_id = as_subquery(2), visit_occurrence_id = as_subquery(1),
                     drug_concept_id = as_subquery(19078728), quantity = as_subquery(8.0),
                     drug_source_concept_id = as_subquery(2030008867), drug_source_value = "152991",
                     days_supply = as_subquery(1))
expect_drug_exposure(drug_exposure_id = as_subquery(2), person_id = as_subquery(2), visit_occurrence_id = as_subquery(2),
                     drug_concept_id = as_subquery(40162361),
                     drug_source_concept_id = as_subquery(2030008694), drug_source_value = "144493",
                     days_supply = as_subquery(1))

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
