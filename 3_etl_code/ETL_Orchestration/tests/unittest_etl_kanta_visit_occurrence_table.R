# DESCRIPTION:
# Unit tests for etl_kanta_visit_occurrence.
# Default mother birth_date is 1959-01-01
# PARAMETERS:
#
# Test ids: 27xx
# Finngenids: FG27xxyyy

# Declare Test - 2701 - default
declareTest(2701, "etl_kanta_visit_occurrence works with defaults")
add_finngenid_info(
  finngenid="FG2701001"
)

add_kanta(
  finngenid = "FG2701001",
  event_age = as_subquery(68.05),
  approx_event_datetime = "2021-01-29T00:00:00",
  test_name = "e-mcv",
  test_id = "1357",
  test_id_system = NULL,
  concept_id = as_subquery(3024731),
  measurement_value = as_subquery(93.0),
  measurement_unit = "fl",
  measurement_value_harmonized = as_subquery(93.0),
  measurement_unit_harmonized = "fl",
  result_abnormality = NULL,
  measurement_status = NULL,
  reference_range_min_value = NULL,
  reference_range_max_value = NULL,
  coding_system = "Helsinki_8817",
  test_id_source = "1357",
  test_name_source = "E-MCV",
  measurement_value_source = as_subquery(93.0),
  measurement_unit_source = "fL"
)
#
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG2701001"),
  visit_concept_id = as_subquery(32036),
  visit_start_date = "2021-01-29",
  visit_start_datetime = "2021-01-29T00:00:00",
  visit_end_date = "2021-01-29",
  visit_end_datetime = "2021-01-29T00:00:00",
  visit_type_concept_id = as_subquery(32879),
  provider_id = lookup_provider("provider_id", provider_source_value = "Helsinki_8817"),
  care_site_id = NULL,
  visit_source_value = "SOURCE=KANTA;INDEX=",
  visit_source_concept_id = as_subquery(2002330245),
  admitted_from_concept_id = as_subquery(0),
  admitted_from_source_value = NULL,
  discharged_to_concept_id = as_subquery(0),
  discharged_to_source_value = NULL,
  preceding_visit_occurrence_id = NULL
)


# Declare Test - 2702 - correct visit concept id for kanta
declareTest(2702, "etl_kanta_visit_occurrence correct visit concept id 32036 Laboratory Visit")
add_finngenid_info(
  finngenid="FG2702001"
)

add_kanta(
  finngenid = "FG2702001",
  approx_event_datetime = "2021-01-29T00:00:00",
  test_name = "e-mcv",
  concept_id = as_subquery(3024731),
  measurement_value = as_subquery(93.0),
  measurement_unit = "fl",
  measurement_value_harmonized = as_subquery(93.0),
  measurement_unit_harmonized = "fl"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG2702001"),
  visit_concept_id = as_subquery(32036),
  visit_source_value = "SOURCE=KANTA;INDEX=",
  visit_source_concept_id = as_subquery(2002330245)
)
