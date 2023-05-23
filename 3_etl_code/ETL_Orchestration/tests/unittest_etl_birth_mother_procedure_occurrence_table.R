# DESCRIPTION:
# Unit tests for etl_birth_mother for procedure occurrence table.
# For this unit test PLEASE add other registry event
# apart from BIRTH_MOTHER registry for visit_occurrence table
# through which these tables are filled out.
# PARAMETERS:
#
# Test ids: 13xx
# Finngenids: FG013xxyyy

# Declare Test - 1301 - Find standard condition code in birth mother registry
declareTest(1301, "etl_procedure_occurrence adds one row for code with standard mapping for source birth_mother")

add_finngenid_info(
  finngenid="FG1301001"
)
# INPAT
add_hilmo(
  finngenid = "FG1301001",
  source = "INPAT",
  index = "FG1301001-1"
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
# OUTPAT
add_hilmo(
  finngenid = "FG1302001",
  source = "OUTPAT",
  index = "FG1302001-1"
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
# PURCH
add_purch(
  finngenid = "FG1303001",
  source = "PURCH",
  index = "FG1303001-1"
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
# INPAT
add_prim_out(
  finngenid = "FG1304001",
  source = "PRIM_OUT",
  index = "FG1304001-1"
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
