# ETL vDF13.3

- ETL for FinnGen DF13 v3
- Registers: Service-sector-data, birth mother, vision, kidney and Kanta drug registries
- Bug fixes and improvements in concept hierarchy
- Kanta lab values 2.0
- FinOMOP vocabulary updated to August 2025 OMOP vocabulary release

# ETL vDF13.2
- ETL for FinnGen DF13 v2
- Registers: Service-sector-data, birth mother, vision, kidney and Kanta drug registries
- Drug exposure will capture source registry from Kanta or Kela registries
- Concept hierarchy now has self reference to ancestor and descandant concepts

# ETL vDF13.1
- ETL for FinnGen DF13
- Registers: Service-sector-data, birth mother, vision, kidney and Kanta drug registries
- Kidney, Vision and Birth mother R13 version released
- Provider table SQL fixed for updates from FinOMOP vocabulary

# ETL vDF13.0

- ETL for FinnGen DF13
- Registers: Service-sector-data, birth mother, vision, kidney and Kanta drug registries
- Kidney, Vision and Birth mother R12 were used

# ETL vDF12.0

- ETL for FinnGen DF11
- Registers: Service-sector-data, birth mother, vision, kidney, Biobank and Kanta lab value registries
- Fixed birth mother registry SQL and tests to utilize newly introduced `APPROX_DELIVERY_DATE` column
- Added entire framework for Kanta lab values including SQL and tests
- Added entire framework for Kidney registry including SQL and tests
- Added SQL for achilles result concept count to capture person and record counts for both standard and non-standard concepts 

# ETL vDF11.0

- ETL for FinnGen DF11
- Registers: Service-sector-data
- Updated DEATH register in etl_input schema to death_register due to conflict in concept
- Vocabulary and CDM tables are same dataset in Sandbox
- Minor SQL fixes to device_exposure, drug_exposure, person, observation, drug_era and measurement tables
- Addition of documenation pages


# ETL vDF10.0

- ETL for FinnGen DF10
- Registers: Service-sector-data
- Unit tests for CDM tables
- Stem table introduction
- Bash script to download BigQuery tables into csv files for different table size
