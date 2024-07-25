# DESCRIPTION:
# Unit tests for etl_kanta_to_measurement.
#
# PARAMETERS:
#
# Test ids: 28xx
# Finngenids: FG28xxyyy

# Declare Test - 2801 - Default values
declareTest(2801, "etl_measurement works for default values for source kanta")

add_finngenid_info(
  finngenid="FG2801001",
)
# KANTA
add_kanta(
  finngenid = "FG2801001",
  approx_event_datetime = "2021-01-29T00:00:00",
  test_name = "e-mcv",
  concept_id = as_subquery(3024731),
  measurement_value = as_subquery(93.0),
  measurement_unit = "fl",
  measurement_value_harmonized = as_subquery(93.0),
  measurement_unit_harmonized = "fl",
  coding_system = "Helsinki_8817",
  test_name_source = "E-MCV",
  measurement_value_source = as_subquery(93.0),
  measurement_unit_source = "fL"
)

expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG2801001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG2801001"),
                                                visit_source_value = "SOURCE=KANTA;INDEX="),
  measurement_concept_id = as_subquery(3024731),
  measurement_date = "2021-01-29",
  measurement_datetime = "2021-01-29T00:00:00",
  measurement_time = "00:00:00",
  measurement_type_concept_id = as_subquery(32879),
  operator_concept_id = as_subquery(0),
  value_as_number = as_subquery(93.0),
  value_as_concept_id = as_subquery(0),
  unit_concept_id = as_subquery(8583),
  range_low = NULL,
  range_high = NULL,
  provider_id = lookup_provider("provider_id", provider_source_value = "Helsinki_8817"),
  visit_detail_id = NULL,
  measurement_source_value = "E-MCV",
  measurement_source_concept_id = as_subquery(2002402146),
  unit_source_value = "fL",
  unit_source_concept_id = as_subquery(2002500127),
  value_source_value = "93",
  measurement_event_id = NULL,
  meas_event_field_concept_id = as_subquery(0)
)


# Declare Test - 2802 - Negative value lab test should be one of the accepted OHDSI standard codes
declareTest(2802, "etl_measurement adds one row for negative value measurement test only when it belongs to OHDSI acceptable list")

add_finngenid_info(
  finngenid="FG2802001"
)
# KANTA
add_kanta(
  finngenid = "FG2802001",
  event_age = as_subquery(68.05),
  approx_event_datetime = "2021-01-29T00:00:00",
  test_name = "vb-be",
  concept_id = as_subquery(3002032),
  measurement_value = as_subquery(-16.7),
  measurement_unit = "mmol/l",
  measurement_value_harmonized = as_subquery(-16.7),
  measurement_unit_harmonized = "mmol/l",
  test_name_source = "vB-BE",
  measurement_value_source = as_subquery(-16.7),
  measurement_unit_source = "mmol/L"
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG2802001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG2802001"),
                                                visit_source_value = "SOURCE=KANTA;INDEX="),
  measurement_concept_id = as_subquery(3002032),
  value_as_number = as_subquery(-16.7),
  unit_concept_id = as_subquery(8753),
  unit_source_value = "mmol/L",
  unit_source_concept_id = as_subquery(2002500183),
  measurement_source_value = "vB-BE",
  measurement_source_concept_id = as_subquery(2002409277)
)

# Declare Test - 2803 - Negative value lab test will be NULL if it is not in one of the accepted OHDSI standard codes
declareTest(2803, "etl_measurement adds one row but will have value NULL when negative lab test is not present in OHDSI standard")

add_finngenid_info(
  finngenid="FG2803001"
)
# KANTA
add_kanta(
  finngenid = "FG2803001",
  approx_event_datetime = "2021-01-29T00:00:00",
  test_name = "e-mcv",
  concept_id = as_subquery(-1),
  measurement_value = as_subquery(-16.7),
  measurement_unit = "fl",
  measurement_value_harmonized = as_subquery(-16.7),
  measurement_unit_harmonized = "fl",
  coding_system = "Helsinki_8817",
  test_name_source = "E-MCV",
  measurement_value_source = as_subquery(-16.7),
  measurement_unit_source = "fL"
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG2803001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG2803001"),
                                                visit_source_value = "SOURCE=KANTA;INDEX="),
  measurement_concept_id = as_subquery(-1),
  measurement_date = "2021-01-29",
  measurement_datetime = "2021-01-29T00:00:00",
  measurement_time = "00:00:00",
  value_as_number = NULL,
  unit_concept_id = as_subquery(8583),
  measurement_source_value = "E-MCV",
  measurement_source_concept_id = as_subquery(2002402146),
  unit_source_value = "fL",
  unit_source_concept_id = as_subquery(2002500127),
  value_source_value = "-16.7"
)
