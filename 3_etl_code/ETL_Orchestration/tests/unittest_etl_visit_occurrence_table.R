# DESCRIPTION:
# Unit tests for etl_visit_occurrence.
#
# PARAMETERS:
#
# Test ids: 03xx
# Finngenids: FG0030xxyyy

# Declare Test - 0301 - defaut
declareTest(0301, "etl_visit_occurrence works with defauls")
add_finngenid_info(
  finngenid="FG00301001"
  )
add_purch(
  finngenid = "FG00301001",
  source = "PURCH",
  event_age = as_subquery(47.26),
  approx_event_day = "1994-01-08",
  index = "FG00301001-1")
#
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG00301001"),
  visit_concept_id = as_subquery(581458),
  visit_start_date = "1994-01-08",
  visit_start_datetime = "1994-01-08T00:00:00",
  visit_end_date = "1994-01-08",
  visit_end_datetime = "1994-01-08T00:00:00",
  visit_type_concept_id = as_subquery(32879),
  provider_id = as_subquery(0),
  care_site_id = as_subquery(0),
  visit_source_value = "SOURCE=PURCH;INDEX=FG00301001-1",
  visit_source_concept_id = as_subquery(2101400101),
  admitted_from_concept_id = as_subquery(0),
  admitted_from_source_value = NULL,
  discharged_to_concept_id = as_subquery(0),
  discharged_to_source_value = NULL,
  preceding_visit_occurrence_id = as_subquery(0)
)


# Declare Test - 0302 - correct ids for purch reimb canc death
declareTest(0302, "etl_visit_occurrence works with defauls")
add_finngenid_info(
  finngenid="FG00302001"
)

add_purch(
  finngenid = "FG00302001",
  source = "PURCH",
  index = "FG00302001-1"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG00302001"),
  visit_concept_id = as_subquery(581458),
  visit_source_value = "SOURCE=PURCH;INDEX=FG00302001-1",
  visit_source_concept_id = as_subquery(2101400101)
)

add_reimb(
  finngenid = "FG00302001",
  source = "REIMB",
  index = "FG00302001-1"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG00302001"),
  visit_concept_id = as_subquery(38004193),
  visit_source_value = "SOURCE=REIMB;INDEX=FG00302001-1",
  visit_source_concept_id = as_subquery(2101400102)
)

add_canc(
  finngenid = "FG00302001",
  source = "CANC",
  index = "FG00302001-1"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG00302001"),
  visit_concept_id = as_subquery(38004268),
  visit_source_value = "SOURCE=CANC;INDEX=FG00302001-1",
  visit_source_concept_id = as_subquery(2101400103)
)

add_death(
  finngenid = "FG00302001",
  source = "DEATH",
  index = "FG00302001-1"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG00302001"),
  visit_concept_id = as_subquery(0),
  visit_source_value = "SOURCE=DEATH;INDEX=FG00302001-1",
  visit_source_concept_id = as_subquery(2101400104)
)


# Declare Test - 0303 - prim out maps correctly
declareTest(0303, "etl_visit_occurrence maps prim_out visits correctly")
add_finngenid_info(
  finngenid="FG00303001"
)

add_prim_out(
  finngenid = "FG00303001",
  source = "PRIM_OUT",
  code5_contact_type = NULL,
  code6_service_sector = NULL,
  index = "FG00303001-1"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG00303001"),
  visit_concept_id = as_subquery(38004193),
  visit_source_value = "SOURCE=PRIM_OUT;INDEX=FG00303001-1",
  visit_source_concept_id = as_subquery(2101300644)
)

add_prim_out(
  finngenid = "FG00303001",
  source = "PRIM_OUT",
  code5_contact_type = NULL,
  code6_service_sector = "T31",
  index = "FG00303001-2"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG00303001"),
  visit_concept_id = as_subquery(9202),
  visit_source_value = "SOURCE=PRIM_OUT;INDEX=FG00303001-2",
  visit_source_concept_id = as_subquery(2101300624)
)

add_prim_out(
  finngenid = "FG00303001",
  source = "PRIM_OUT",
  code5_contact_type = "R51",
  code6_service_sector = NULL,
  index = "FG00303001-3"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG00303001"),
  visit_concept_id = as_subquery(38004193),
  visit_source_value = "SOURCE=PRIM_OUT;INDEX=FG00303001-3",
  visit_source_concept_id = as_subquery(2101300324)
)

add_prim_out(
  finngenid = "FG00303001",
  source = "PRIM_OUT",
  code5_contact_type = "R50",
  code6_service_sector = "T40",
  index = "FG00303001-4"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG00303001"),
  visit_concept_id = as_subquery(5083),
  visit_source_value = "SOURCE=PRIM_OUT;INDEX=FG00303001-4",
  visit_source_concept_id = as_subquery(2101300274)
)




# Declare Test - 0304 - hilmo OUPAT  maps correctly
declareTest(0304, "etl_visit_occurrence maps OUPAT visits correctly")
add_finngenid_info(
  finngenid="FG00304001"
)

add_hilmo(
  finngenid = "FG00304001",
  source = "OUTPAT",
  code5_service_sector = NULL,
  code8_contact_type = NULL,
  code9_urgency = NULL,
  index = "FG00304001-1"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG00304001"),
  visit_concept_id = as_subquery(9202),
  visit_source_value = "SOURCE=OUTPAT;INDEX=FG00304001-1",
  visit_source_concept_id = as_subquery(2101100206)
)


#Declare Test - 0305 - hilmo OPER_OUT  maps correctly
#declareTest(0305, "etl_visit_occurrence maps OPER_OUT visits correctly")


# Declare Test - 0306 - hilmo INPAT  maps correctly
declareTest(0306, "etl_visit_occurrence maps INPAT visits correctly for ndays=1 and ndays>1")
add_finngenid_info(
  finngenid="FG00306001"
)

add_hilmo(
  finngenid = "FG00306001",
  source = "INPAT",
  approx_event_day = "1999-01-08",
  code4_hospital_days_na = 0,
  code5_service_sector = NULL,
  code8_contact_type = NULL,
  code9_urgency = NULL,
  index = "FG00306001-1"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG00306001"),
  visit_concept_id = as_subquery(9202),
  visit_source_value = "SOURCE=INPAT;INDEX=FG00306001-1",
  visit_source_concept_id = as_subquery(2101100205)
)

add_hilmo(
  finngenid = "FG00306001",
  source = "INPAT",
  approx_event_day = "1999-01-08",
  code4_hospital_days_na = 1,
  code5_service_sector = NULL,
  code8_contact_type = NULL,
  code9_urgency = NULL,
  index = "FG00306001-2"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG00306001"),
  visit_concept_id = as_subquery(9201),
  visit_source_value = "SOURCE=INPAT;INDEX=FG00306001-2",
  visit_source_concept_id = as_subquery(2101100205)
)

# Declare Test - 0307 - visit_source_concept_id missign mapping is not skipped
declareTest(0307, "etl_visit_occurrence sets visit_concept_id to 0 when code in visit_source_concept_id has no mapping")
add_finngenid_info(
  finngenid="FG00307001"
)

add_hilmo(
  finngenid = "FG00307001",
  source = "INPAT",
  approx_event_day = "1999-01-08",
  code1_icd_symptom_operation_code = "Y95",
  index = "FG00307001-1"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG00307001"),
  visit_concept_id = as_subquery(0),
  visit_source_value = "SOURCE=INPAT;INDEX=FG00307001-1",
  visit_source_concept_id = as_subquery(2101100197)
)




















