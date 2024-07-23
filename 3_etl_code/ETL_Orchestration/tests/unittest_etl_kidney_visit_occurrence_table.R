# DESCRIPTION:
# Unit tests for etl_kidney_visit_occurrence.
# Default birth_date is 1959-01-01
# PARAMETERS:
#
# Test ids: 21xx
# Finngenids: FG021xxyyy

# Declare Test - 2101 - default
declareTest(2101, "etl_kidney_visit_occurrence works with defaults")

add_finngenid_info(
  finngenid="FG2101001"
)
# KIDNEY
add_kidney(
  finngenid = "FG2101001",
  event_age = as_subquery(26.0),
  approx_event_day = "1985-01-01",
  start_year = NULL,
  kidney_disease_diagnosis_1 = "N083",
  kidney_disease_diagnosis_2 = NULL,
  era_edta_diagnosis = NULL,
  edta_diagnosis_old = NULL,
  approx_end_date_of_tracking = NULL,
  end_of_tracking_age = NULL,
  height = NULL,
  weight = NULL,
  systolic_blood_pressure = NULL,
  diastolic_blood_pressure = NULL,
  cholesterol = NULL,
  hdl_cholesterol = NULL,
  triglyceride = NULL,
  previous = NULL,
  current = NULL,
  approx_start_date_of_nerf_tracking = NULL,
  start_of_nerf_tracking_age = NULL,
  angina_pectoris = NULL,
  heart_attack = NULL,
  bypass_or_other_procedure = NULL,
  left_ventricular_hypertrophy = NULL,
  heart_failure = NULL,
  other_vascular_disease = NULL,
  other_vascular_disease_entry = NULL,
  other_vascular_disease_amputation = NULL,
  dyslipidemia_diet_treatment = NULL,
  dyslipidemia_medical_treatment = NULL,
  stroke = NULL,
  rr_medical_treatment = NULL,
  t1d = NULL,
  t2d = NULL,
  unknown_type_of_diabetes = NULL,
  iv_iron = NULL,
  vitamin_d_treatment = NULL,
  epo_treatment = NULL,
  fistula_in_first_dialysis_treatment = NULL,
  approx_diabetes_date = NULL,
  diabetes_age = NULL,
  reason_for_termination_of_active_treatment = NULL,
  previous_form_of_treatment = NULL,
  current_form_of_treatment = NULL,
  type_of_change = NULL,
  year = NULL,
  fistula = NULL,
  antihypertensive_drug = NULL,
  esa_treatment = NULL,
  dialysis_per_week = NULL,
  dialysis_h_per_week = NULL,
  azathioprine = NULL,
  ciclosporin = NULL,
  tacrolimus = NULL,
  mycophenolate = NULL,
  steroids = NULL,
  other_immunosuppressive = NULL,
  on_transfer_list_or_not = NULL,
  production_of_urine = NULL,
  peritonitis_per_year = NULL
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG2101001"),
  visit_concept_id = as_subquery(9202),
  visit_start_date = "1985-01-01",
  visit_start_datetime = "1985-01-01T00:00:00",
  visit_end_date = "1985-01-01",
  visit_end_datetime = "1985-01-01T00:00:00",
  visit_type_concept_id = as_subquery(32879),
  provider_id = NULL,
  care_site_id = NULL,
  visit_source_value = "SOURCE=KIDNEY;INDEX=1",
  visit_source_concept_id = as_subquery(2002330186),
  admitted_from_concept_id = as_subquery(0),
  admitted_from_source_value = NULL,
  discharged_to_concept_id = as_subquery(0),
  discharged_to_source_value = NULL,
  preceding_visit_occurrence_id = NULL
)


# Declare Test - 2102 - correct visit concept id for kidney registry visit
declareTest(2102, "etl_kidney_visit_occurrence correct visit concept id 9202 Outpatient Visit")

add_finngenid_info(
  finngenid = "FG2102001"
)
# KIDNEY
add_kidney(
  finngenid = "FG2102001"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG2102001"),
  visit_concept_id = as_subquery(9202),
  visit_source_value = "SOURCE=KIDNEY;INDEX=2",
  visit_source_concept_id = as_subquery(2002330186)
)

# Declare Test - 2103 - prevlaence visits with no APPROX_EVENT_DAY will be added as new visit at end of year using YEAR
declareTest(2103, "etl_kidney_visit_occurrence adds two rows for incidence approx_event_day and prevalence visit check up as end of year")

add_finngenid_info(
  finngenid="FG2103001"
)
# KIDNEY
add_kidney(
  finngenid = "FG2103001",
  event_age = as_subquery(46.0),
  approx_event_day = "2005-01-01",
  start_year = as_subquery(2005)
)
add_kidney(
  finngenid = "FG2103001",
  event_age = NULL,
  approx_event_day = NULL,
  start_year = NULL,
  year = as_subquery(2006)

)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG2103001"),
  visit_concept_id = as_subquery(9202),
  visit_start_date = "2005-01-01",
  visit_source_value = "SOURCE=KIDNEY;INDEX=3",
  visit_source_concept_id = as_subquery(2002330186)
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG2103001"),
  visit_concept_id = as_subquery(9202),
  visit_start_date = "2006-12-31",
  visit_source_value = "SOURCE=KIDNEY;INDEX=4",
  visit_source_concept_id = as_subquery(2002330186)
)

# Declare Test - 2104 - prevlaence visits YEAR+`12-31` date same as APPROX_EVENT_DAY will be considered as same visit
declareTest(2104, "etl_kidney_visit_occurrence adds a row when prevalence visit date coincides with APPROX_EVENT_DAY from incidence")

add_finngenid_info(
  finngenid="FG2104001"
)
# KIDNEY
add_kidney(
  finngenid = "FG2104001",
  event_age = as_subquery(47.96),
  approx_event_day = "2006-12-31",
  start_year = as_subquery(2005)
)
add_kidney(
  finngenid = "FG2104001",
  event_age = NULL,
  approx_event_day = NULL,
  start_year = NULL,
  year = as_subquery(2006)

)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG2104001"),
  visit_concept_id = as_subquery(9202),
  visit_start_date = "2006-12-31",
  visit_source_value = "SOURCE=KIDNEY;INDEX=5",
  visit_source_concept_id = as_subquery(2002330186)
)

# Declare Test - 2105 - treatment columns are repeated because of change in TYPE_OF_CHANGE despite having same APPROX_EVENT_DAY will have one visit
declareTest(2105, "etl_kidney_visit_occurrence adds a row when treatment has repeated rows with different type_of_change but with same approx_event_day")

add_finngenid_info(
  finngenid="FG2105001"
)
# KIDNEY
add_kidney(
  finngenid = "FG2105001",
  event_age = as_subquery(46.0),
  approx_event_day = "2005-01-01",
  previous_form_of_treatment = as_subquery(21),
  current_form_of_treatment = as_subquery(51),
  type_of_change = "H"
)
add_kidney(
  finngenid = "FG2105001",
  event_age = as_subquery(46.0),
  approx_event_day = "2005-01-01",
  previous_form_of_treatment = as_subquery(21),
  current_form_of_treatment = as_subquery(51),
  type_of_change = "T"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG2105001"),
  visit_concept_id = as_subquery(9202),
  visit_start_date = "2005-01-01",
  visit_source_value = "SOURCE=KIDNEY;INDEX=6",
  visit_source_concept_id = as_subquery(2002330186)
)






