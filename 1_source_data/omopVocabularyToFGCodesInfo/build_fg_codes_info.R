
library(tidyverse)
library(ROMOPMappingTools)
library(checkmate)
library(readxl)
library(validate)



# paths -------------------------------------------------------------------
path_to_omop_vocabulary_folder <- here::here("../../../GITLAB_FinOMOP/finomop_omop_vocabulary/OMOP_VOCABULARIES/output_omop_vocabulary/")
path_to_endpoint_definitions_xlsx <- here::here("../DATA/endpoint_definitions/FINNGEN_ENDPOINTS_DF11_Final_2022-10-05_public.xlsx")

path_to_output_fg_codes_info <- here::here("../DATA/fg_codes_info/fg_codes_info.csv")

# load data ---------------------------------------------------------------
omop_tables <- ROMOPMappingTools::importOMOPtables(path_to_omop_vocabulary_folder, c("CONCEPT", "CONCEPT_SYNONYM"))

concept <- omop_tables |>
  filter(name=="CONCEPT") |> 
  purrr::pluck("table", 1)

synonym_fi <- omop_tables |>
  filter(name=="CONCEPT_SYNONYM") |> 
  purrr::pluck("table", 1) |> 
  filter(language_concept_id==4181730) |> 
  select(concept_id, concept_name_fi = concept_synonym_name)

# uncomment to get the endpoint definitions
# endpoint_definitions <- readxl::read_excel(path_to_endpoint_definitions_xlsx) |>
#   slice(-1) |>
#   mutate(LONGNAME = str_remove(LONGNAME, '\\n') )|>
#   mutate(LONGNAME = str_remove(LONGNAME, '\\r') )

# MEDICAL CODES -----------------------------------------------------------
# - for ICD10 ignore these invalid codes saying "do not use"
# - for ICD10 ignore "ICD10 SubChapter" or "ICD10 Chapter"
# - merge icd10 with ICD10fi
# - some icdo3 have a NULL ?? dont know why, but they are invalid
# - soem icdo3 are clasification codes xxx or xxx-xxx

medical_codes_vocabulary_ids <- c(
  "ATC",
  "FHL",
  "HPN",
  "HPO",
  "ICD10",
  "ICD10fi",
  "ICD9fi",
  "ICD8fi",
  "ICDO3",
  "ICPC",
  "NCSPfi",
  "REIMB",
  "SPAT", 
  "VNRfi"
)

medical_codes_concepts <- concept |> 
  filter(vocabulary_id %in% medical_codes_vocabulary_ids)|> 
  # ICD10 
  # for ICD10 ignore these invalid codes saying "do not use"
  filter(!(vocabulary_id == "ICD10" & !is.na(invalid_reason) & str_detect(concept_name, "do not use"))) |> 
  # for ICD10 ignore "ICD10 SubChapter"
  filter(!(vocabulary_id == "ICD10" & concept_class_id %in% c("ICD10 SubChapter", "ICD10 Chapter"))) |> 
  # merge icd10 with ICD10fi
  mutate(vocabulary_id = if_else(vocabulary_id=="ICD10", "ICD10fi", vocabulary_id)  ) |> 
  # ICDO3
  # some icdo3 have a NULL ?? dont know why, but they are invalid
  filter(!(vocabulary_id=="ICDO3" & str_detect(concept_code, "NULL"))) |> 
  # soem icdo3 are clasification codes xxx or xxx-xxx
  filter(!(vocabulary_id=="ICDO3" & str_detect(concept_code, "^[:digit:]{3}-[:digit:]{3}$"))) |>
  filter(!(vocabulary_id=="ICDO3" & str_detect(concept_code, "^[:digit:]{3}$"))) |> 
  filter(concept_id != 44498515)


medical_codes_fg_codes_info <- medical_codes_concepts |>
  # add name fi
  left_join(synonym_fi, by = "concept_id") |> 
  #
  transmute(
    FG_CODE1 = case_when(
      vocabulary_id == "ICD10fi" ~ concept_code |>
        str_replace_all("\\+|\\*|\\#|\\&|\\.","") |>
        str_extract("^[:upper:]([:digit:]|[:upper:])[:digit:][:digit:]?[:digit:]?"), # ([:digit:]|[:upper:]) is to cover some ZA codes
      vocabulary_id == "ICDO3" ~ concept_code |>
        str_replace("\\.", "") |>
        str_extract("[:alpha:][:digit:]+"),
      TRUE ~ concept_code
    ),
    FG_CODE2 = case_when(
      vocabulary_id == "ICD10fi" ~ concept_code |>
        str_replace_all("\\+|\\*|\\#|\\&|\\.","") |>
        str_extract("[:digit:][:upper:][:digit:][:digit:][:digit:]?[:digit:]?") |>
        str_sub(2,100),
      vocabulary_id == "ICDO3" ~ concept_code |>
        str_extract("^[:digit:]+/") |>
        str_replace("/", ""),
      TRUE ~ as.character(NA)
    ),
    FG_CODE3 = case_when(
      vocabulary_id == "ICDO3" ~ concept_code |>
        str_extract("/[:digit:]") |>
        str_replace_all("/", ""),
      TRUE ~ as.character(NA)
    ), 
    #
    code = concept_code, 
    vocabulary_id = vocabulary_id, 
    concept_class_id = concept_class_id, 
    name_en = concept_name,  
    name_fi = concept_name_fi,  
    omop_concept_id=concept_id
  ) 

### Remove duplicates
# - in REIMB there are some duplicates with different time at the moment take only one
medical_codes_fg_codes_info <- medical_codes_fg_codes_info |>
  filter( !(vocabulary_id=="REIMB" & ( omop_concept_id %in% c(2001600267 , 2001600268, 2001600159))) )


# ENDPOINTS  --------------------------------------------------------------

# uncomment to add the endpoint definitions

# endpoints_fg_codes_info <- endpoint_definitions |> 
#   transmute(
#   FG_CODE1 = NAME,
#   code = NAME,
#   vocabulary_id = "FG_ENDPOINT",
#   concept_class_id = TAGS,
#   name_en = LONGNAME,
#   name_fi = as.character(NA), 
#   omop_concept_id = 0L
# )



# SERVICE SECTOR ----------------------------------------------------------

service_sector_concepts <- concept |> 
  filter(vocabulary_id %in% "FGVisitType") 

service_sector_fg_codes_info <- service_sector_concepts |> 
  # add name fi
  left_join(synonym_fi, by = "concept_id") |> 
  #
  transmute(
    FG_CODE1 = as.character(NA),
    FG_CODE2 = as.character(NA),
    FG_CODE3 = as.character(NA),
    #
    SOURCE =  case_when(
      concept_class_id == "SRC" ~ concept_code, 
      TRUE ~ (concept_code |>  str_extract("^([:upper:]|_)+\\|") |> str_remove("\\|"))
      ),
    #
    FG_CODE5 = case_when(
      concept_class_id == "SRC|ServiceSector" ~ (concept_code |>  str_extract("\\|[:alnum:]+$") |> str_remove("\\|")), 
      concept_class_id == "SRC|Contact|Service" ~ (concept_code |>  str_extract("\\|[:alnum:]+\\|") |> str_remove_all("\\|")),
      TRUE ~ as.character(NA)
    ),
    FG_CODE6 = case_when(
      concept_class_id == "SRC|Contact|Service" ~ (concept_code |>  str_extract("\\|[:alnum:]+$") |> str_remove_all("\\|")),
      TRUE ~ as.character(NA)
    ),
    FG_CODE8 = case_when(
      concept_class_id == "SRC|Contact|Urgency" ~ (concept_code |>  str_extract("\\|[:alnum:]+\\|") |> str_remove_all("\\|")),
      TRUE ~ as.character(NA)
    ),
    FG_CODE9 = case_when(
      concept_class_id == "SRC|Contact|Urgency" ~ (concept_code |>  str_extract("\\|[:alnum:]+$") |> str_remove_all("\\|")),
      TRUE ~ as.character(NA)
    ),
    #
    code = concept_code,
    vocabulary_id = vocabulary_id,
    concept_class_id = concept_class_id,
    name_en = concept_name,
    name_fi = concept_name_fi, 
    omop_concept_id = concept_id
  ) |> 
  # replace 0 with NA in CODE 5 to 9
  mutate_at(
    vars(FG_CODE5, FG_CODE6, FG_CODE8, FG_CODE9), 
    ~if_else(.=="0", as.character(NA), .)
    )

### Remove duplicates
# FG_CODE5=NA FG_CODE8=NA FG_CODE9=NA points to 2 codes INPAT|0 and INPAT|0|0
# We force all to be INPAT|0, as it occures during all times and has less precision
service_sector_fg_codes_info <- service_sector_fg_codes_info |>
  filter( !( code %in% c("INPAT|0|0", "OUTPAT|0|0", "OPER_IN|0|0", "OPER_OUT|0|0")))

# SPECIALITY ----------------------------------------------------------

speciality_concepts <- concept |> 
  filter(vocabulary_id %in% "MEDSPECfi") 

speciality_fg_codes_info <- speciality_concepts |> 
  # add name fi
  left_join(synonym_fi, by = "concept_id") |> 
  #
  transmute(
    FG_CODE1 = as.character(NA),
    FG_CODE2 = as.character(NA),
    FG_CODE3 = as.character(NA),
    SOURCE = as.character(NA),
    FG_CODE5 = as.character(NA),
    #
    FG_CODE6 = concept_code,
    FG_CODE8 = as.character(NA),
    FG_CODE9 = as.character(NA),
    #
    code = concept_code,
    vocabulary_id = vocabulary_id,
    concept_class_id = concept_class_id,
    name_en = concept_name,
    name_fi = concept_name_fi, 
    omop_concept_id = concept_id
  )

# PROFESSIONAL CODED ------------------------------------------------------

professional_concepts <- concept |> 
  filter(vocabulary_id %in% "ProfessionalCode") 

professional_fg_codes_info <- professional_concepts |> 
  # add name fi
  left_join(synonym_fi, by = "concept_id") |> 
  #
  transmute(
    FG_CODE1 = as.character(NA),
    FG_CODE2 = as.character(NA),
    FG_CODE3 = as.character(NA),
    SOURCE = as.character(NA),
    FG_CODE5 = as.character(NA),
    #
    FG_CODE6 = as.character(NA),
    FG_CODE7 = concept_code,
    FG_CODE8 = as.character(NA),
    FG_CODE9 = as.character(NA),
    #
    code = concept_code,
    vocabulary_id = vocabulary_id,
    concept_class_id = concept_class_id,
    name_en = concept_name,
    name_fi = concept_name_fi, 
    omop_concept_id = concept_id
  )


# join all  ---------------------------------------------------------------

fg_codes_info <- bind_rows(
 medical_codes_fg_codes_info, 
 #endpoints_fg_codes_info,  #uncomment when endpoints are added
 service_sector_fg_codes_info, 
 speciality_fg_codes_info, 
 professional_fg_codes_info
) |>  
  select(
    FG_CODE1, FG_CODE2, FG_CODE3,
    SOURCE,   FG_CODE5, FG_CODE6, FG_CODE7, FG_CODE8, FG_CODE9,
    code, vocabulary_id, concept_class_id, name_en, name_fi,
    omop_concept_id
    )



# TESTING -----------------------------------------------------------------

## Summary
fg_codes_info |>  count(vocabulary_id)

## Table validation 

rules <- validate::validator(
  `unique vocabulary_id, SOURCE, FG_CODE` = is_unique(vocabulary_id, FG_CODE1, FG_CODE2, FG_CODE3, SOURCE, FG_CODE5, FG_CODE6, FG_CODE7, FG_CODE8, FG_CODE9), 
  is_complete(code), 
  is_complete(vocabulary_id), 
  is_complete(name_en), 
  is_complete(omop_concept_id)
)

out   <- validate::confront(fg_codes_info, rules)

validate::summary(out)

validate::violating(fg_codes_info, out)

## TEMP: Include all codes from the translations ??

trans_atc <- read_tsv("../INPUT_FILES/FINNGEN_TRANSLATIONS/ATC_translate_minimal.txt", show_col_types = FALSE) |> 
  select(Id, Longname)

trans_atc |> 
  anti_join(
    fg_codes_info |>  filter(vocabulary_id == "ATC") |> rename(Id = FG_CODE1)
  )

# trans_meds <- read_tsv("../INPUT_FILES/FINNGEN_TRANSLATIONS/finngen_R6_medcode_ref.tsv", show_col_types = FALSE) |> 
#   filter(code_set != "ICD10")
# 
# trans_meds |> 
#   anti_join(
#     fg_codes_info |>   rename(code_set  = vocabulary_id ), 
#     by = c("code_set", "code")
#   )

# Save --------------------------------------------------------------------

fg_codes_info |> write_tsv(path_to_output_fg_codes_info)
































