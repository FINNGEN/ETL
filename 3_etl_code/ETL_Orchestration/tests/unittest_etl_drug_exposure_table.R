










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
