# DESCRIPTION:
# Unit tests for etl_birth_mother for condition occurrence table.
# For this unit test PLEASE add other registry event
# apart from BIRTH_MOTHER registry for visit_occurrence table
# through which these tables are filled out.
# PARAMETERS:
#
# Test ids: 12xx
# Finngenids: FG012xxyyy

# Declare Test - 1201 - Find standard condition code in birth mother registry
declareTest(1201, "etl_condition_occurrence adds one row for code with standard mapping for source birth_mother")

add_finngenid_info(
  finngenid="FG1201001"
)
# INPAT
add_hilmo(
  finngenid = "FG1201001",
  source = "INPAT",
  index = "FG1201001-1"
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
# OUTPAT
add_hilmo(
  finngenid = "FG1202001",
  source = "OUTPAT",
  index = "FG1202001-1"
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
# PURCH
add_purch(
  finngenid = "FG1203001",
  source = "PURCH",
  index = "FG1203001-1"
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
# INPAT
add_prim_out(
  finngenid = "FG1204001",
  source = "PRIM_OUT",
  index = "FG1204001-1"
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
# INPAT
add_prim_out(
  finngenid = "FG1205001",
  source = "PRIM_OUT",
  index = "FG1205001-1"
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
# INPAT
add_canc(
  finngenid = "FG1206001",
  source = "CANC",
  index = "FG1206001-1"
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
