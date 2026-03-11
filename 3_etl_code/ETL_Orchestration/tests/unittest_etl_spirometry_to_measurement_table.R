# DESCRIPTION:
# Unit tests for etl_spirometry_to_measurement.
#
# PARAMETERS:
#
# Test ids: 30xx
# Finngenids: FG30xxyyy

# Declare Test - 3001 - Default values
declareTest(3001, "etl_measurement works for default values for source kanta")

add_finngenid_info(
  finngenid="FG3001001",
)
# SPIROMETRY
add_spirometry(
  finngenid = "FG3001001",
  approx_date = "2021-01-29",
  source = "Helsinki",
  fev1_best = as_subquery(2.0),
  fvc_best = NULL,
  fev1_fvc_ratio = NULL,
  fev1_max = NULL,
  fvc_max = NULL,
  measurement_type = "reversibility",
  fev1_post = NULL,
  fvc_post = NULL,
  fev1_fvc_post = NULL,
  fev1_change_l = NULL,
  fev1_change_pct = NULL,
  fvc_change_l = NULL,
  fvc_change_pct = NULL
)

expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG3001001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG3001001"),
                                                visit_source_value = "SOURCE=HELSINKI;INDEX="),
  measurement_concept_id = as_subquery(3024653),
  measurement_date = "2021-01-29",
  measurement_datetime = "2021-01-29T00:00:00",
  measurement_time = "00:00:00",
  measurement_type_concept_id = as_subquery(32879),
  operator_concept_id = as_subquery(0),
  value_as_number = as_subquery(2.0),
  value_as_concept_id = as_subquery(0),
  unit_concept_id = as_subquery(8519),
  range_low = NULL,
  range_high = NULL,
  provider_id = NULL,
  visit_detail_id = NULL,
  measurement_source_value = "FEV1_BEST",
  measurement_source_concept_id = as_subquery(2002330271),
  unit_source_value = "l",
  unit_source_concept_id = as_subquery(2001800124),
  value_source_value = NULL,
  measurement_event_id = NULL,
  meas_event_field_concept_id = as_subquery(0)
)
