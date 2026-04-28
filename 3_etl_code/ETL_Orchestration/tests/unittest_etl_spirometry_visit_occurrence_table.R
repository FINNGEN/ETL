# DESCRIPTION:
# Unit tests for etl_spirometry_visit_occurrence.
# PARAMETERS:
#
# Test ids: 29xx
# Finngenids: FG29xxyyy

# Declare Test - 2901 - default
declareTest(2901, "etl_spirometry_visit_occurrence works with defaults")
add_finngenid_info(
  finngenid="FG2901001"
)

add_spirometry(
  finngenid = "FG2901001",
  approx_date = "2021-01-29",
  source = "Helsinki",
  sex = "female",
  birth_date = "1953-08-08",
  age_at_test = as_subquery(68.05),
  age_group = NULL,
  is_pediatric = NULL,
  height_best = as_subquery(160.0),
  height_clean = as_subquery(160.0),
  height_flag = "ok",
  weight_median = as_subquery(80.0),
  weight_latest = as_subquery(70.0),
  weight_clean = as_subquery(70.0),
  weight_flag = "ok",
  fev1_best = as_subquery(2.0),
  fvc_best = as_subquery(2.5),
  fev1_fvc_ratio = as_subquery(0.8),
  fev1_max = as_subquery(2.0),
  fvc_max = as_subquery(2.5),
  measurement_type = "reversibility",
  fev1_post = as_subquery(2.1),
  fvc_post = as_subquery(2.5),
  fev1_fvc_post = as_subquery(0.81),
  fev1_change_l = as_subquery(0.1),
  fev1_change_pct = as_subquery(5.0),
  fvc_change_l = as_subquery(0.1),
  fvc_change_pct = as_subquery(4.0),
  significant_response = "FALSE",
  obstruction = "Normal"
)
#
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG2901001"),
  visit_concept_id = as_subquery(33004),
  visit_start_date = "2021-01-29",
  visit_start_datetime = "2021-01-29T00:00:00",
  visit_end_date = "2021-01-29",
  visit_end_datetime = "2021-01-29T00:00:00",
  visit_type_concept_id = as_subquery(32879),
  provider_id = NULL,
  care_site_id = NULL,
  visit_source_value = "SOURCE=HELSINKI;INDEX=",
  visit_source_concept_id = as_subquery(2002330270),
  admitted_from_concept_id = as_subquery(0),
  admitted_from_source_value = NULL,
  discharged_to_concept_id = as_subquery(0),
  discharged_to_source_value = NULL,
  preceding_visit_occurrence_id = NULL
)


# Declare Test - 2902 - correct visit concept id for spirometry
declareTest(2902, "etl_spirometry_visit_occurrence correct visit concept id 33004 Supplier / Service Provider")
add_finngenid_info(
  finngenid="FG2902001"
)

add_spirometry(
  finngenid = "FG2902001",
  approx_date = "2021-01-29",
  source = "Tampere",
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG2902001"),
  visit_concept_id = as_subquery(33004),
  visit_source_value = "SOURCE=TAMPERE;INDEX=",
  visit_source_concept_id = as_subquery(2002330269)
)
