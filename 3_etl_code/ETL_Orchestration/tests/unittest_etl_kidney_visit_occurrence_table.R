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

add_kidney(
  finngenid <- "FG2101001",
  event_age <- as_subquery(26.0),
  approx_event_day <- "1985-01-01",
  start_year <- NULL,
  kidney_disease_diagnosis_1 <- "N083",
  kidney_disease_diagnosis_2 <- NULL,
  era_edta_diagnosis <- NULL,
  edta_diagnosis_old <- NULL,
  approx_end_date_of_tracking <- NULL,
  end_of_tracking_age <- NULL,
  height <- NULL,
  weight <- NULL,
  systolic_blood_pressure <- NULL,
  diastolic_blood_pressure <- NULL,
  cholesterol <- NULL,
  hdl_cholesterol <- NULL,
  triglyceride <- NULL,
  previous <- as_subquery(0),
  current <- as_subquery(0),
  approx_start_date_of_nerf_tracking <- NULL,
  start_of_nerf_tracking_age <- NULL,
  angina_pectoris <- as_subquery(0),
  heart_attack <- as_subquery(0),
  bypass_or_other_procedure <- as_subquery(0),
  left_ventricular_hypertrophy <- as_subquery(0),
  heart_failure <- as_subquery(0),
  other_vascular_disease <- as_subquery(0),
  other_vascular_disease_entry <- as_subquery(0),
  other_vascular_disease_amputation <- as_subquery(0),
  dyslipidemia_diet_treatment <- as_subquery(0),
  dyslipidemia_medical_treatment <- NULL,
  stroke <- as_subquery(0),
  rr_medical_treatment <- as_subquery(0),
  t1d <- as_subquery(0),
  t2d <- as_subquery(0),
  unknown_type_of_diabetes <- as_subquery(0),
  iv_iron <- as_subquery(0),
  vitamin_d_treatment <- as_subquery(0),
  epo_treatment <- as_subquery(0),
  fistula_in_first_dialysis_treatment <- NULL,
  approx_diabetes_date <- NULL,
  diabetes_age <- NULL,
  reason_for_termination_of_active_treatment <- NULL,
  previous_form_of_treatment <- NULL,
  current_form_of_treatment <- NULL,
  type_of_change <- NULL,
  year <- NULL,
  fistula <- NULL,
  antihypertensive_drug <- as_subquery(0),
  esa_treatment <- as_subquery(0),
  dialysis_per_week <- NULL,
  dialysis_h_per_week <- NULL,
  azathioprine <- as_subquery(0),
  ciclosporin <- as_subquery(0),
  tacrolimus <- as_subquery(0),
  mycophenolate <- as_subquery(0),
  steroids <- as_subquery(0),
  other_immunosuppressive <- NULL,
  on_transfer_list_or_not <- NULL,
  production_of_urine <- NULL,
  peritonitis_per_year <- NULL
)
#
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


# Declare Test - 2102 - correct ids for kidney
declareTest(2102, "etl_kidney_visit_occurrence correct visit concept id 9202 Outpatient Visit")
add_finngenid_info(
  finngenid="FG2102001"
)

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









