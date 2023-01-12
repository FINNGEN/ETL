# Declare Tests
declareTest(0401, "Drug Exposure mappings - Multiple ingredients with liquid dosage form with no CODE4 package")
# Add Finngenid_info
add_finngenid_info(finngenid="FG0401001", sex="female",
                   bl_year = as_subquery(1992),bl_age = as_subquery(46.0),
                   approx_birth_date = "1947-05-18", fu_end_age = as_subquery(74.31))
# Add PURCH registry
add_purch(finngenid = "FG0401001", source = "PURCH",event_age = as_subquery(56.0), approx_event_day = "2010-03-31",
          code1_atc_code = "S01ED51", code3_vnro = "068220",index = "100" )
# Expect the drug exposure - For Finngenid FG0401001
expect_drug_exposure(#drug_exposure_id = as_subquery(1),
                     person_id = lookup_person("person_id", person_source_value="FG0401001"), visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id", person_id = lookup_person("person_id", person_source_value="FG0401001"), visit_source_value = "SOURCE=PURCH;INDEX=100"),
                     drug_concept_id = as_subquery(902427), quantity = as_subquery(9.0),
                     drug_exposure_start_date = "2010-03-31", drug_exposure_start_datetime = "2010-03-31T00:00:00",
                     drug_exposure_end_date = "2010-04-09", drug_exposure_end_datetime = "2010-04-09T00:00:00",
                     drug_type_concept_id = as_subquery(32879),
                     drug_source_concept_id = as_subquery(2030000182), drug_source_value = "068220",
                     days_supply = as_subquery(1), route_source_value = "Ocular use")
expect_drug_exposure(#drug_exposure_id = as_subquery(2),
                     person_id = lookup_person("person_id", person_source_value="FG0401001"), visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id", person_id = lookup_person("person_id", person_source_value="FG0401001"), visit_source_value = "SOURCE=PURCH;INDEX=100"),
                     drug_concept_id = as_subquery(904525), quantity = as_subquery(9.0),
                     drug_exposure_start_date = "2010-03-31", drug_exposure_start_datetime = "2010-03-31T00:00:00",
                     drug_exposure_end_date = "2010-04-09", drug_exposure_end_datetime = "2010-04-09T00:00:00",
                     drug_type_concept_id = as_subquery(32879),
                     drug_source_concept_id = as_subquery(2030000182), drug_source_value = "068220",
                     days_supply = as_subquery(1), route_source_value = "Ocular use")


# Declare Tests
declareTest(0402, "Drug Exposure mappings - Multiple ingredients with Solid dosage form with CODE4 package value")
# Add Finngenid_info
add_finngenid_info(finngenid="FG0402001", sex="female",
                   bl_year = as_subquery(1992),bl_age = as_subquery(46.0),
                   approx_birth_date = "1947-05-18", fu_end_age = as_subquery(74.31))
# Add PURCH registry
add_purch(finngenid = "FG0402001", source = "PURCH",event_age = as_subquery(56.0), approx_event_day = "2010-03-31",
          code1_atc_code = "J01CR02", code3_vnro = "1154", code4_plkm = "2", index = "101" )
# Expect the drug exposure - For Finngenid FG0402001
expect_drug_exposure(#drug_exposure_id = as_subquery(1),
                     person_id = lookup_person("person_id", person_source_value="FG0402001"), visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id", person_id = lookup_person("person_id", person_source_value="FG0402001"), visit_source_value = "SOURCE=PURCH;INDEX=101"),
                     drug_concept_id = as_subquery(1713332), quantity = as_subquery(24.0),
                     drug_exposure_start_date = "2010-03-31", drug_exposure_start_datetime = "2010-03-31T00:00:00",
                     drug_exposure_end_date = "2010-04-24", drug_exposure_end_datetime = "2010-04-24T00:00:00",
                     drug_type_concept_id = as_subquery(32879),
                     drug_source_concept_id = as_subquery(2030000049), drug_source_value = "001154",
                     days_supply = as_subquery(1), route_source_value = "Oral use")
expect_drug_exposure(#drug_exposure_id = as_subquery(2),
                     person_id = lookup_person("person_id", person_source_value="FG0402001"), visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id", person_id = lookup_person("person_id", person_source_value="FG0402001"), visit_source_value = "SOURCE=PURCH;INDEX=101"),
                     drug_concept_id = as_subquery(1759842), quantity = as_subquery(24.0),
                     drug_exposure_start_date = "2010-03-31", drug_exposure_start_datetime = "2010-03-31T00:00:00",
                     drug_exposure_end_date = "2010-04-24", drug_exposure_end_datetime = "2010-04-24T00:00:00",
                     drug_type_concept_id = as_subquery(32879),
                     drug_source_concept_id = as_subquery(2030000049), drug_source_value = "001154",
                     days_supply = as_subquery(1), route_source_value = "Oral use")


# Declare Tests
declareTest(0403, "Drug Exposure mappings - Single ingredient with solid dosage form with CODE4 package value")
# Add Finngenid_info
add_finngenid_info(finngenid="FG0403001", sex="male",
                   bl_year = as_subquery(2010),bl_age = as_subquery(43.5),
                   approx_birth_date = "1967-06-15", fu_end_age = as_subquery(55.53))
# Add PURCH registry
add_purch(finngenid = "FG0403001", source = "PURCH", event_age = as_subquery(52.5), approx_event_day = "2019-01-01",
          code1_atc_code = "J02AC02", code3_vnro = "152991", code4_plkm = "2", index = "102" )
# Expect the drug exposure - For Finngenid FG0403001
expect_drug_exposure(drug_exposure_id = as_subquery(1), person_id = lookup_person("person_id", person_source_value="FG0403001"), visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id", person_id = lookup_person("person_id", person_source_value="FG0403001"), visit_source_value = "SOURCE=PURCH;INDEX=102"),
                     drug_concept_id = as_subquery(19078728), quantity = as_subquery(8.0),
                     drug_exposure_start_date = "2019-01-01", drug_exposure_start_datetime = "2019-01-01T00:00:00",
                     drug_exposure_end_date = "2019-01-09", drug_exposure_end_datetime = "2019-01-09T00:00:00",
                     drug_type_concept_id = as_subquery(32879),
                     drug_source_concept_id = as_subquery(2030008867), drug_source_value = "152991",
                     days_supply = as_subquery(1), route_source_value = "Oral use")

# Declare Tests
declareTest(0404, "Drug Exposure mappings - Single ingredient with solid dosage form with no CODE4 package")
# Add Finngenid_info
add_finngenid_info(finngenid="FG0404001", sex="male",
                   bl_year = as_subquery(2010),bl_age = as_subquery(43.5),
                   approx_birth_date = "1967-06-15", fu_end_age = as_subquery(55.53))
# Add PURCH registry
add_purch(finngenid = "FG0404001", source = "PURCH", event_age = as_subquery(53.5), approx_event_day = "2020-10-01",
          code3_vnro = "144493", index = "103" )
# Expect the drug exposure - For Finngenid FG0404001
expect_drug_exposure(drug_exposure_id = as_subquery(1), person_id = lookup_person("person_id", person_source_value="FG0404001"), visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id", person_id = lookup_person("person_id", person_source_value="FG0404001"), visit_source_value = "SOURCE=PURCH;INDEX=103"),
                     drug_concept_id = as_subquery(40162361), quantity = as_subquery(14.0),
                     drug_exposure_start_date = "2020-10-01", drug_exposure_start_datetime = "2020-10-01T00:00:00",
                     drug_exposure_end_date = "2020-10-15", drug_exposure_end_datetime = "2020-10-15T00:00:00",
                     drug_type_concept_id = as_subquery(32879),
                     drug_source_concept_id = as_subquery(2030008694), drug_source_value = "144493",
                     days_supply = as_subquery(1), route_source_value = "Oral use")
