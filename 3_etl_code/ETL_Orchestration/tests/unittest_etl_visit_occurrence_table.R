






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

