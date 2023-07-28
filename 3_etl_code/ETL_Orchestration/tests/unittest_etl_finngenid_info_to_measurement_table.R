# DESCRIPTION:
# Unit tests for etl_finngenid_info_to_measurement.
#
# PARAMETERS:
#
# Test ids: 16xx
# Finngenids: FG16xxyyy

# Declare Test - 1601 - BMI and Height codes will be mapped to proper standard codes
declareTest(1601, "etl_measurement BMI and Height codes will be mapped to standard codes")

add_finngenid_info(
  finngenid="FG1601001",
  bl_year = as_subquery(2000),
  bl_age = as_subquery(46.0),
  sex = "female",
  height = as_subquery(177),
  height_age = NULL,
  weight = as_subquery(72),
  weight_age = NULL,
  smoke2 = NULL,
  smoke3 = NULL,
  smoke5 = NULL,
  smoke_age = NULL,
  regionofbirth = as_subquery(1),
  regionofbirthname = "Uusimaa",
  movedabroad = NULL,
  number_of_offspring = as_subquery(1),
  approx_birth_date = "1954-01-01",
  fu_end_age = as_subquery(60.0)
)

expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG1601001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1601001"),
                                                visit_source_value = "SOURCE=BIOBANK;INDEX="),
  measurement_concept_id = as_subquery(4245997),
  measurement_date = "2000-01-02",
  measurement_datetime = "2000-01-02T00:00:00",
  measurement_time = "00:00:00",
  measurement_type_concept_id = as_subquery(32879),
  operator_concept_id = as_subquery(0),
  value_as_number = as_subquery(22.98),
  value_as_concept_id = as_subquery(0),
  unit_concept_id = as_subquery(0),
  range_low = NULL,
  range_high = NULL,
  provider_id = NULL,
  visit_detail_id = NULL,
  measurement_source_value = "BMI",
  measurement_source_concept_id = as_subquery(2002330107),
  unit_source_value = NULL,
  unit_source_concept_id = as_subquery(0),
  value_source_value = NULL,
  measurement_event_id = NULL,
  meas_event_field_concept_id = as_subquery(0)
)

expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG1601001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1601001"),
                                                visit_source_value = "SOURCE=BIOBANK;INDEX="),
  measurement_concept_id = as_subquery(4177340),
  measurement_date = "2000-01-02",
  measurement_datetime = "2000-01-02T00:00:00",
  measurement_time = "00:00:00",
  measurement_type_concept_id = as_subquery(32879),
  operator_concept_id = as_subquery(0),
  value_as_number = as_subquery(177.0),
  value_as_concept_id = as_subquery(0),
  unit_concept_id = as_subquery(8582),
  range_low = NULL,
  range_high = NULL,
  provider_id = NULL,
  visit_detail_id = NULL,
  measurement_source_value = "HEIGHT",
  measurement_source_concept_id = as_subquery(2002330108),
  unit_source_value = "cm",
  unit_source_concept_id = as_subquery(2001800125),
  value_source_value = NULL,
  measurement_event_id = NULL,
  meas_event_field_concept_id = as_subquery(0)
)

# Declare Test - 1602 - Only Height codes will be mapped to standard codes When Weight variable is missing
declareTest(1602, "etl_measurement adds one row for Height codes ony which will be mapped to standard codes")

add_finngenid_info(
  finngenid="FG1602001",
  height = as_subquery(177),
  weight = NULL
)

expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG1602001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1602001"),
                                                visit_source_value = "SOURCE=BIOBANK;INDEX="),
  measurement_concept_id = as_subquery(4177340),
  value_as_number = as_subquery(177.0),
  unit_concept_id = as_subquery(8582),
  unit_source_value = "cm",
  unit_source_concept_id = as_subquery(2001800125),
  measurement_source_value = "HEIGHT",
  measurement_source_concept_id = as_subquery(2002330108)
)

# Declare Test - 1603 - No BMI or Height codes will be mapped to standard codes When both Height and Weight variables are missing
declareTest(1603, "etl_measurement DOESNOT insert a row when both height and weight variables are missing")

add_finngenid_info(
  finngenid="FG1603001",
  height = NULL,
  weight = NULL
)

expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG1603001")
)
