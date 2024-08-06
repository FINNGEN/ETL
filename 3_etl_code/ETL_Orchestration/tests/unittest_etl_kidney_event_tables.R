# DESCRIPTION:
# Unit tests for etl_kidney for condition, procedure,
# observation, measurement and device tables.
#
# PARAMETERS:
#
# Condition Occurrence
# Test ids: 22xx
# Finngenids: FG022xxyyy
#
# Procedure Occurrence
# Test ids: 23xx
# Finngenids: FG023xxyyy
#
# Measurement
# Test ids: 24xx
# Finngenids: FG024xxyyy
#
# Observation
# Test ids: 25xx
# Finngenids: FG025xxyyy
#
# Device
# Test ids: 26xx
# Finngenids: FG026xxyyy

# CONDITION OCCURRENCE ------------------------------------------------------------------------------------

# Declare Test - 2201 - Default values
declareTest(2201, "etl_condition_occurrence adds a row for default values for source kidney")

add_finngenid_info(
  finngenid = "FG2201001"
)
# KIDNEY
add_kidney(
  finngenid = "FG2201001"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG2201001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG2201001"),
                                                visit_source_value = "SOURCE=KIDNEY;INDEX=7"),
  condition_concept_id = as_subquery(4137220),
  condition_source_value = "CODE1=N083;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(45592124)
)

# Declare Test - 2202 - Find standard condition code in kidney registry
declareTest(2202, "etl_condition_occurrence adds one row for combination diagnosis code with standard mapping for source kidney")

add_finngenid_info(
  finngenid="FG2202001"
)
# KIDNEY
add_kidney(
  finngenid = "FG2202001",
  approx_event_day = "1994-01-08",
  kidney_disease_diagnosis_1 = "N0839*E102"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG2202001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG2202001"),
                                                visit_source_value = "SOURCE=KIDNEY;INDEX=8"),
  condition_concept_id = as_subquery(200687),
  condition_source_value = "CODE1=N0839;CODE2=E102;CODE3=",
  condition_source_concept_id = as_subquery(2000503132)
)

# PROCEDURE OCCURRENCE ------------------------------------------------------------------------------------

# Declare Test - 2301 - Find standard procedure code in kidney registry
declareTest(2301, "etl_procedure_occurrence adds one row for code with standard mapping for source kidney")

add_finngenid_info(
  finngenid="FG2301001"
)
# KIDNEY
add_kidney(
  finngenid = "FG2301001",
  approx_event_day = "1994-01-08",
  bypass_or_other_procedure = as_subquery(1)
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG2301001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG2301001"),
                                                visit_source_value = "SOURCE=KIDNEY;INDEX=9"),
  procedure_concept_id = as_subquery(4042673),
  procedure_source_value = "1",
  procedure_source_concept_id = as_subquery(2002330196)
)

# MEASUREMENT ----------------------------------------------------------------------------------------------------------------

# Declare Test - 2401 - Find standard measurement code in kidney registry
declareTest(2401, "etl_measurement adds one row for code with standard mapping for source kidney")

add_finngenid_info(
  finngenid="FG2401001"
)
# KIDNEY
add_kidney(
  finngenid = "FG2401001",
  approx_event_day = "1994-01-08",
  systolic_blood_pressure = as_subquery(120)
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG2401001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG2401001"),
                                                visit_source_value = "SOURCE=KIDNEY;INDEX=10"),
  measurement_concept_id = as_subquery(3004249),
  unit_concept_id = as_subquery(8876),
  value_as_number = as_subquery(120),
  measurement_source_value = "SYSTOLIC_BLOOD_PRESSURE",
  measurement_source_concept_id = as_subquery(2002330189),
  unit_source_value = 'mmhg',
  unit_source_concept_id = as_subquery(2002500178)
)

# Declare Test - 2402 - Cholesterol measurement should have mmol/l unit and properly mapped in measurement domain
declareTest(2402, "etl_measurement adds a row for cholesterol with standard mapping in measurement domain for source kidney")

add_finngenid_info(
  finngenid="FG2402001"
)
# KIDNEY
add_kidney(
  finngenid = "FG2402001",
  approx_event_day = "1994-01-08",
  cholesterol = as_subquery(2.6)
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG2402001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG2402001"),
                                                visit_source_value = "SOURCE=KIDNEY;INDEX=11"),
  measurement_concept_id = as_subquery(3019900),
  value_as_number = as_subquery(2.6),
  unit_concept_id = as_subquery(8753),
  measurement_source_value = "CHOLESTEROL",
  measurement_source_concept_id = as_subquery(2002330191),
  unit_source_value = 'mmol/l',
  unit_source_concept_id = as_subquery(2002500183)
)

# OBSERVATION ----------------------------------------------------------------------------------------------------------------

# Declare Test - 2501 - Find standard observation code in kidney registry
declareTest(2501, "etl_observation adds one row for code with standard mapping in observation domain for source kidney")

add_finngenid_info(
  finngenid="FG2501001"
)
# KIDNEY
add_kidney(
  finngenid = "FG2501001",
  approx_event_day = "1994-01-08",
  rr_medical_treatment = as_subquery(1)
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG2501001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG2501001"),
                                                visit_source_value = "SOURCE=KIDNEY;INDEX=12"),
  observation_concept_id = as_subquery(40761399),
  observation_source_value = "1",
  observation_source_concept_id = as_subquery(2002330205)
)

# Declare Test - 2502 - Kidney sample with production of urine observation should have unit ml
declareTest(2502, "etl_observation adds a row for urine production observation with standard mapping in observation domain for source kidney")

add_finngenid_info(
  finngenid="FG2502001"
)
# KIDNEY
add_kidney(
  finngenid = "FG2502001",
  approx_event_day = "1994-01-08",
  production_of_urine = as_subquery(1800)
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG2502001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG2502001"),
                                                visit_source_value = "SOURCE=KIDNEY;INDEX=13"),
  observation_concept_id = as_subquery(4299925),
  unit_concept_id = as_subquery(8587),
  value_as_number = as_subquery(1800),
  observation_source_value = "PRODUCTION_OF_URINE",
  observation_source_concept_id = as_subquery(2002330226),
  unit_source_value = "ml"
)

# DEVICE ----------------------------------------------------------------------------------------------------------------

# Declare Test - 2601 - Find standard device code in kidney registry
declareTest(2601, "etl_device_exposure adds one row for code with standard mapping in device domain for source kidney")

add_finngenid_info(
  finngenid="FG2601001"
)
# KIDNEY
add_kidney(
  finngenid = "FG2601001",
  approx_event_day = "1994-01-08",
  fistula = as_subquery(3)
)
expect_device_exposure(
  person_id = lookup_person("person_id", person_source_value="FG2601001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG2601001"),
                                                visit_source_value = "SOURCE=KIDNEY;INDEX=14"),
  device_concept_id = as_subquery(4314784),
  device_source_value = "3",
  device_source_concept_id = as_subquery(2002330214)
)
