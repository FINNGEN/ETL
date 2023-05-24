# DESCRIPTION:
# Unit tests for etl_birth_mother for condition, procedure,
# observation and measurement tables.
#
# PARAMETERS:
#
# Condition Occurrence
# Test ids: 12xx
# Finngenids: FG012xxyyy
#
# Condition Occurrence
# Test ids: 13xx
# Finngenids: FG013xxyyy
#
# Measurement
# Test ids: 14xx
# Finngenids: FG014xxyyy
#
# Observation
# Test ids: 15xx
# Finngenids: FG015xxyyy

# CONDITION OCCURRENCE ------------------------------------------------------------------------------------

# Declare Test - 1201 - Find standard condition code in birth mother registry
declareTest(1201, "etl_condition_occurrence adds one row for code with standard mapping for source birth_mother")

add_finngenid_info(
  finngenid="FG1201001"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1201001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "O365"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1201001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1201001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  condition_concept_id = as_subquery(72693),
  condition_source_value = "CODE1=O365;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(45592238)
)

# Declare Test - 1202 - Mother with two diagnosis codes that are non-null and both fall in condition domain
declareTest(1202, "etl_condition_occurrence adds two rows for two diagnosis codes with standard mapping in condition domain for source birth_mother")

add_finngenid_info(
  finngenid="FG1202001"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1202001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "6440A",
  sdiag2 = "6488A"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1202001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1202001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  condition_concept_id = as_subquery(4273560),
  condition_source_value = "CODE1=6440A;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(2000405054)
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1202001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1202001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  condition_concept_id = as_subquery(438480),
  condition_source_value = "CODE1=6488A;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(2000405097)
)

# Declare Test - 1203 - Mother with two diagnosis codes that are non-null but one has standard map in condition and other in procedure
declareTest(1203, "etl_condition_occurrence adds only one row for the diagnosis code with standard mapping in condition but not for diagnosis code in procedure domain for source birth_mother")

add_finngenid_info(
  finngenid="FG1203001"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1203001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "O9989",
  sdiag2 = "Z302"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1203001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1203001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  condition_concept_id = as_subquery(435875),
  condition_source_value = "CODE1=O9989;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(2000503220)
)

# Declare Test - 1204 - Mother with diagnosis code that is non-null but has standard maps to both condition and procedure domain
declareTest(1204, "etl_condition_occurrence adds only one row for a diagnosis code with standard mapping to 2 codes one condition and one procedure for source birth_mother")

add_finngenid_info(
  finngenid="FG1204001"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1204001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "O8210"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1204001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1204001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  condition_concept_id = as_subquery(4066112),
  condition_source_value = "CODE1=O8210;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(2000503217)
)

# Declare Test - 1205 - Mother with diagnosis code that is non-null but has no standard map
declareTest(1205, "etl_condition_occurrence adds a row for a diagnosis code with no standard mapping for source birth_mother")

add_finngenid_info(
  finngenid="FG1205001"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1205001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "6670A"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1205001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1205001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  condition_concept_id = as_subquery(0),
  condition_source_value = "CODE1=6670A;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(2000405303)
)

# Declare Test - 1206 - Mother with diagnosis code that is non-null but has no non-standard map
declareTest(1206, "etl_condition_occurrence adds a row for a diagnosis code with no non-standard mapping for source birth_mother")

add_finngenid_info(
  finngenid="FG1206001"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1206001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "V220A"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1206001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1206001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  condition_concept_id = as_subquery(0),
  condition_source_value = "CODE1=V220A;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(0)
)

# PROCEDURE OCCURRENCE ------------------------------------------------------------------------------------

# Declare Test - 1301 - Find standard condition code in birth mother registry
declareTest(1301, "etl_procedure_occurrence adds one row for code with standard mapping for source birth_mother")

add_finngenid_info(
  finngenid="FG1301001"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1301001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "Z018"
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1301001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1301001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  procedure_concept_id = as_subquery(4194672),
  procedure_source_value = "Z018",
  procedure_source_concept_id = as_subquery(45581003)
)

# Declare Test - 1302 - Mother with two diagnosis codes that are non-null and both fall in procedure domain
declareTest(1302, "etl_procedure_occurrence adds two rows for two diagnosis codes with standard mapping in procedure domain for source birth_mother")

add_finngenid_info(
  finngenid="FG1302001"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1302001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "Z018",
  sdiag2 = "Z718"
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1302001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1302001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  procedure_concept_id = as_subquery(4194672),
  procedure_source_value = "Z018",
  procedure_source_concept_id = as_subquery(45581003)
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1302001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1302001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  procedure_concept_id = as_subquery(4254477),
  procedure_source_value = "Z718",
  procedure_source_concept_id = as_subquery(45581061)
)

# Declare Test - 1303 - Mother with two diagnosis codes that are non-null but one has standard map in condition and other in procedure
declareTest(1303, "etl_procedure_occurrence adds only one row for the diagnosis code with standard mapping in procedure but not for diagnosis code in condition domain for source birth_mother")
add_finngenid_info(
  finngenid="FG1303001"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1303001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "O9989",
  sdiag2 = "Z302"
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1303001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1303001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  procedure_concept_id = as_subquery(45766058),
  procedure_source_value = "Z302",
  procedure_source_concept_id = as_subquery(45609921)
)

# Declare Test - 1304 - Mother with diagnosis code that is non-null but has standard maps to both condition and procedure domain
declareTest(1304, "etl_procedure_occurrence adds only one row for a diagnosis code with standard mapping to 2 codes one condition and one procedure for source birth_mother")

add_finngenid_info(
  finngenid="FG1304001"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1304001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "O8210"
)
expect_procedure_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG1304001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1304001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  procedure_concept_id = as_subquery(4167089),
  procedure_source_value = "O8210",
  procedure_source_concept_id = as_subquery(2000503217)
)

# MEASUREMENT ----------------------------------------------------------------------------------------------------------------

# Declare Test - 1401 - Find standard condition code in birth mother registry
declareTest(1401, "etl_measurement adds one row for code with standard mapping for source birth_mother")

add_finngenid_info(
  finngenid="FG1401001"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1401001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "Z363"
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG1401001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1401001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  measurement_concept_id = as_subquery(36713462),
  measurement_source_value = "Z363",
  measurement_source_concept_id = as_subquery(45581023)
)

# Declare Test - 1402 - Mother with two diagnosis codes that are non-null and both fall in measurement domain
declareTest(1402, "etl_measurement adds two rows for two diagnosis codes with standard mapping in measurement domain for source birth_mother")

add_finngenid_info(
  finngenid="FG1402001"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1402001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "Z360",
  sdiag2 = "Z368"
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG1402001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1402001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  measurement_concept_id = as_subquery(43020943),
  measurement_source_value = "Z360",
  measurement_source_concept_id = as_subquery(45571345)
)
expect_measurement(
  person_id = lookup_person("person_id", person_source_value="FG1402001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1402001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  measurement_concept_id = as_subquery(4087235),
  measurement_source_value = "Z368",
  measurement_source_concept_id = as_subquery(45542422)
)

# Declare Test - 1403 - Mother with two diagnosis codes that are non-null but one has standard map in measurement and other in procedure

# Declare Test - 1404 - Mother with diagnosis code that is non-null but has standard maps to both measurement and procedure domain


# OBSERVATION ----------------------------------------------------------------------------------------------------------------

# Declare Test - 1501 - Find standard condition code in birth mother registry
declareTest(1501, "etl_observation adds one row for code with standard mapping for source birth_mother")

add_finngenid_info(
  finngenid="FG1501001"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1501001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "Z348"
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1501001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1501001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  observation_concept_id = as_subquery(4047564),
  observation_source_value = "Z348",
  observation_source_concept_id = as_subquery(45537628)
)

# Declare Test - 1502 - Mother with two diagnosis codes that are non-null and both fall in measurement domain
declareTest(1502, "etl_observation adds two rows for two diagnosis codes with standard mapping in measurement domain for source birth_mother")

add_finngenid_info(
  finngenid="FG1502001"
)
# BIRTH_MOTHER
add_birth_mother(
  mother_finngenid = "FG1502001",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08",
  sdiag1 = "Z340",
  sdiag2 = "Z392"
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1502001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1502001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  observation_concept_id = as_subquery(4061424),
  observation_source_value = "Z340",
  observation_source_concept_id = as_subquery(45595500)
)
expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1502001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1502001"),
                                                visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX="),
  observation_concept_id = as_subquery(36713471),
  observation_source_value = "Z392",
  observation_source_concept_id = as_subquery(45547306)
)

# Declare Test - 1503 - Mother with two diagnosis codes that are non-null but one has standard map in observation and other in condition

# Declare Test - 1504 - Mother with diagnosis code that is non-null but has standard maps to both observation and condition domain


