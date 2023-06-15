drop table source_data.dummydata;
create table source_data.dummydata                                                                                                                                                                                                                                                                              
(
	finngenid text,
	source text,
	event_age numeric,
	approx_event_day date,
	code1 text,
	code2 text,
	code3 text,
	code4 text,
	code5 text,
	code6 text,
	code7 text,
	code8 text,
	code9 text,
	icdver text,
	category text,
	index text
);

copy source_data.dummydata
from '/Users/annavirtanen/Documents/PL/Projektit/Finregistry/git/ETL/1_generate_dummy_data/dummy_service_sector_R11v1.csv' 
delimiter E'\t'  
csv 
null 'NA' 
header;


drop table source_data.finngenid_info;
create table source_data.finngenid_info 
(
	FINNGENID text,
	BL_YEAR int,
	BL_AGE numeric,	
	SEX	text,
	HEIGHT int,
	HEIGHT_AGE numeric,
	WEIGHT int,
	WEIGHT_AGE numeric,
	SMOKE2 text,
	SMOKE3 text,
	SMOKE5 text,
	SMOKE_AGE numeric,
	regionofbirth int,
	regionofbirthname text,
	movedabroad int,
	NUMBER_OF_OFFSPRING int,
	COHORT text,
	FU_END_AGE numeric,
	DEATH text,
	DEATH_AGE text,
	DEATH_YEAR text,
	APPROX_BIRTH_DATE date
);

copy source_data.finngenid_info
from '/Users/annavirtanen/Documents/PL/Projektit/Finregistry/git/ETL/1_generate_dummy_data/dummy_minimum_extended_R11v1.csv' 
delimiter E'\t' 
csv 
null 'NA' 
header;


drop table source_data.fg_codes_info;
create table source_data.fg_codes_info 
(
    FG_CODE1 text,
    FG_CODE2 text,
    FG_CODE3 text,
    SOURCE text,
    FG_CODE5 text,
    FG_CODE6 text,
    FG_CODE7 text,
    FG_CODE8 text,
    FG_CODE9 text,
    code text,
    vocabulary_id text,
    concept_class_id text,
    name_en text,
    name_fi text,
    omop_concept_id int
);

copy source_data.fg_codes_info 
from '/Users/annavirtanen/Documents/PL/Projektit/Finregistry/git/ETL/1_generate_dummy_data/fg_codes_info.csv' 
delimiter E'\t' 
csv  
null 'NA' 
header;