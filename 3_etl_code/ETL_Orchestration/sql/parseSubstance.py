def parseSubstance(englishName,finnishName):
    if englishName == finnishName:
        finnishName = ''
        if any(substring in englishName for substring in [', COMBINATIONS',' COMBINATIONS ',' INCLUDING COMBINATIONS','TEARS AND OTHER','-INHIBITOR,',', NORMAL HUMAN, FOR ','INSULINS AND ANALOGUES ', 'OPIUM DERIVATIVES AND EXPECTORANTS']):
            englishName = englishName
        elif englishName == 'LEVODOPA, DECARBOXYLASE INHIBITOR AND COMT INHIBITOR':
            englishName = 'LEVODOPA'
        elif ' AND ' in englishName:
            englishName = englishName.split(' AND ')[0]
        else:
            englishName = englishName
    elif englishName != finnishName:
        if finnishName == 'NA':
            englishName = englishName
            finnishName = ''
        elif englishName == 'NORETHINDRONE ACETATE':
            englishName = englishName
            finnishName = ''
        elif englishName == 'BETA-LACTAMASE INHIBITOR' or englishName == 'PSYCHOLEPTICS' or englishName == 'THIAZIDES':
            englishName = ''
            finnishName = ''
        elif englishName == 'DAPAGLIFLOZIN' and finnishName == 'SAXAGLIPTIN AND DAPAGLIFLOZIN':
            englishName = englishName
            finnishName = finnishName.split(' AND ')[1]
        elif englishName == 'ERTUGLIFLOZIN' and finnishName == 'SITAGLIPTIN AND ERTUGLIFLOZIN':
            englishName = englishName
            finnishName = finnishName.split(' AND ')[1]
        elif englishName == 'SITAGLIPTIN' and finnishName == 'SITAGLIPTIN AND ERTUGLIFLOZIN':
            englishName = englishName
            finnishName = finnishName.split(' AND ')[0]
        elif englishName == 'FACTOR VIII' and finnishName == 'VON WILLEBRAND FACTOR AND COAGULATION FACTOR VIII IN COMBINATION':
            englishName = englishName
            finnishName = ''
        elif englishName == 'INSULIN (BIOSYNTHETIC; HUMAN)' or englishName == 'ISOPHANE INSULIN (BIOSYNTHETIC HUMAN)':
            englishName = englishName
            finnishName = finnishName
        elif '<>' in englishName:
            if englishName in ['FACTOR VIII <> VON WILLEBRAND FACTOR']:
                englishName = englishName.split(' <> ')[0]
                finnishName = ''
            else:
                englishName = englishName.split(' <> ')[0]
                finnishName = finnishName.split(', ')[0]
        elif ',' not in englishName and ', ' in finnishName:
            englishName = englishName
            if englishName in ['(S)-LACTIC ACID','ACETYLSALICYLIC ACID','AMITRIPTYLINE HYDROCHLORIDE','AMLODIPINE BESILATE',
                           'BENSERAZIDE HYDROCHLORIDE','BETAMETHASONE','BETAMETHASONE SODIUM PHOSPHATE',
                           'BUPIVACAINE HYDROCHLORIDE','CARBIDOPA MONOHYDRATE','CHLORDIAZEPOXIDE','CHLORHEXIDIN DIGLUCONATE',
                           'CHLORHEXIDIN DIGLUCONATE 20% W/V','CHOLECALCIFEROL','CHOLECALCIFEROL (PULVIS)','CHOLECALCIFEROL (VITAMIN D3)',
                           'CLAVULANIC ACID','CLIOQUINOL','CLOSTRIDIOPEPTIDASE A','CODEINE PHOSPHATE HEMIHYDRATE','DEXPANTHENOL',
                           'DIAZEPAM','DROSPIRENONE','ECONAZOLE NITRATE','ENTACAPONE','ESOMEPRAZOLE MAGNESIUM TRIHYDRATE',
                           'ETHINYLESTRADIOL','ETHYLMORPHINE HYDROCHLORIDE','FENOTEROL HYDROBROMIDE','FLUTICASONE PROPIONATE',
                           'FORMOTEROL FUMARATE DIHYDRATE','GENTAMICIN SULPHATE','GLYCOPYRRONIUM BROMIDE','GUAIFENESIN',
                           'HYDROCHLOROTHIAZIDE','HYDROCORTISONE ACETATE','INDAPAMIDE','LERCANIDIPINE','LEVODOPA',
                           'LIDOCAINE HYDROCHLORIDE','LUTROPIN ALFA','MAGNESIUM SUBCARBONATE (HEAVY)','MEDROXYPROGESTERONE ACETATE',
                           'MEPROBAMATE','METFORMIN HYDROCHLORIDE','MISOPROSTOLE','NALOXONE HYDROCHLORIDE DIHYDRATE','NORETHISTERONE',
                           'NORETHISTERONE ACETATE','NYSTATIN','OLODATEROL HYDROCHLORIDE','OTERACIL','PALONOSETRON HYDROCHLORIDE',
                           'PHENTOLAMINE MESILATE','PHENYLPROPANOLAMINE HYDROCHLORIDE','PILOCARPINE HYDROCHLORIDE','PIOGLITAZONE HYDROCHLORIDE',
                           'PSEUDOEPHEDRINE HYDROCHLORIDE','RAMIPRIL','SALBUTAMOL','SALICYLIC ACID','SIMVASTATIN','SODIUM (S) LACTATE DILUTED',
                           'SODIUM CHLORIDE','SULFADIAZINE','SULFAMETHOXAZOLE','TAMSULOSIN HYDROCHLORIDE','TIMOLOL MALEATE','TIPIRACIL HYDROCHLORIDE',
                           'TRICHLORMETHIAZIDE','VILANTEROL','VILANTEROL TRIFENATATE']:
                finnishName = finnishName.split(', ')[-1]
            elif englishName in ['CALCIUM CHLORIDE DIHYDRATE','GIMERACIL']:
                finnishName = finnishName.split(', ')[1]
            elif englishName in ['MAGNESIUM CHLORIDE HEXAHYDRATE']:
                finnishName = finnishName.split(', ')[2]
            elif englishName in ['SODIUM HYDROGEN CARBONATE']:
                finnishName = finnishName.split(', ')[3]
            else:
                finnishName = finnishName.split(', ')[0]
        elif ', ' in englishName and ', ' in finnishName:
            englishName = englishName.split(', ')[0]
            finnishName = finnishName.split(', ')[0]
    if englishName != finnishName:
        return englishName.title(), finnishName.title()
    else:
        return englishName.title(), ''