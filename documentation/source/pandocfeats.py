#!/usr/bin/python3

import json, io, sys, re

OTLangs = {
  "aa": "AFR", "aae": "SQI", "aao": "ARA", "aat": "SQI", "ab": "ABK", "abh": "ARA",
  "abq": "ABA", "abs": "CPP", "abv": "ARA", "acf": "FAN", "acf": "CPP", "acm": "ARA",
  "acq": "ARA", "acr": "ACR", "acr": "MYN", "acw": "ARA", "acx": "ARA", "acy": "ARA",
  "ada": "DNG", "adf": "ARA", "adp": "DZN", "aeb": "ARA", "aec": "ARA", "af": "AFK",
  "afb": "ARA", "afs": "CPP", "agu": "MYN", "ahg": "AGW", "aht": "ATH", "aig": "CPP",
  "aii": "SWA", "aii": "SYR", "aiw": "ARI", "ajp": "ARA", "ak": "AKA", "akb": "AKB",
  "akb": "BTK", "aln": "SQI", "als": "SQI", "am": "AMH", "amf": "HBN", "amw": "SYR",
  "an": "ARG", "aoa": "CPP", "apa": "ATH", "apc": "ARA", "apd": "ARA", "apj": "ATH",
  "apk": "ATH", "apl": "ATH", "apm": "ATH", "apw": "ATH", "ar": "ARA", "arb": "ARA",
  "arn": "MAP", "arq": "ARA", "ars": "ARA", "ary": "MOR", "ary": "ARA", "arz": "ARA",
  "as": "ASM", "atj": "RCR", "atv": "ALT", "auj": "BBR", "auz": "ARA", "av": "AVR",
  "avl": "ARA", "ay": "AYM", "ayc": "AYM", "ayh": "ARA", "ayl": "ARA", "ayn": "ARA",
  "ayp": "ARA", "ayr": "AYM", "az": "AZE", "azb": "AZB", "azb": "AZE", "azd": "NAH",
  "azj": "AZE", "azn": "NAH", "azz": "NAH", "ba": "BSH", "bad": "BAD0", "bah": "CPP",
  "bai": "BML", "bal": "BLI", "bbc": "BBC", "bbc": "BTK", "bbj": "BML", "bbp": "BAD0",
  "bbz": "ARA", "bcc": "BLI", "bci": "BAU", "bcl": "BIK", "bcq": "BCH", "bcr": "ATH",
  "be": "BEL", "bea": "ATH", "beb": "BTI", "bem": "BEM", "ber": "BBR", "bew": "CPP",
  "bfl": "BAD0", "bfq": "BAD", "bft": "BLT", "bfu": "LAH", "bfy": "BAG", "bg": "BGR",
  "bgn": "BLI", "bgp": "BLI", "bgq": "BGQ", "bgq": "RAJ", "bgr": "QIN", "bhb": "BHI",
  "bhk": "BIK", "bhr": "MLG", "bi": "BIS", "bi": "CPP", "bin": "EDO", "biu": "QIN",
  "bjn": "MLY", "bjo": "BAD0", "bjq": "MLG", "bjs": "CPP", "bjt": "BLN", "bko": "BML",
  "bla": "BKF", "ble": "BLN", "blk": "BLK", "blk": "KRN", "bln": "BIK", "bm": "BMB",
  "bmm": "MLG", "bn": "BEN", "bo": "TIB", "bpd": "BAD0", "bpl": "CPP", "bpq": "CPP",
  "bqi": "LRC", "bqk": "BAD0", "br": "BRE", "bra": "BRI", "brc": "CPP", "bs": "BOS",
  "btb": "BTI", "btd": "BTD", "btd": "BTK", "btj": "MLY", "btm": "BTM", "btm": "BTK",
  "bto": "BIK", "bts": "BTS", "bts": "BTK", "btx": "BTX", "btx": "BTK", "btz": "BTZ",
  "btz": "BTK", "bum": "BTI", "bve": "MLY", "bvu": "MLY", "bwe": "KRN", "bxk": "LUH",
  "bxo": "CPP", "bxp": "BTI", "bxr": "RBU", "byn": "BIL", "byv": "BYV", "byv": "BML",
  "bzc": "MLG", "bzj": "CPP", "bzk": "CPP", "ca": "CAT", "caa": "MYN", "cac": "MYN",
  "caf": "CRR", "caf": "ATH", "cak": "CAK", "cak": "MYN", "cbk": "CBK", "cbk": "CPP",
  "cbl": "QIN", "ccl": "CPP", "ccm": "CPP", "cco": "CCHN", "ccq": "ARK", "cdo": "ZHS",
  "ce": "CHE", "cek": "QIN", "cey": "QIN", "cfm": "HAL", "cfm": "QIN", "ch": "CHA",
  "chf": "MYN", "chj": "CCHN", "chk": "CHK0", "chn": "CPP", "chp": "CHP", "chp": "SAY",
  "chp": "ATH", "chq": "CCHN", "chz": "CCHN", "ciw": "OJB", "cjy": "ZHS", "cka": "QIN",
  "ckb": "KUR", "ckn": "QIN", "cks": "CPP", "ckt": "CHK", "ckz": "MYN", "clc": "ATH",
  "cld": "SYR", "cle": "CCHN", "clj": "QIN", "clt": "QIN", "cmn": "ZHS", "cmr": "QIN",
  "cnb": "QIN", "cnh": "QIN", "cnk": "QIN", "cnl": "CCHN", "cnp": "ZHS", "cnr": "SRB",
  "cnt": "CCHN", "cnu": "BBR", "cnw": "QIN", "co": "COS", "coa": "MLY", "cob": "MYN",
  "coq": "ATH", "cpa": "CCHN", "cpe": "CPP", "cpf": "CPP", "cpi": "CPP", "cpx": "ZHS",
  "cqd": "HMN", "cqu": "QUH", "cqu": "QUZ", "cr": "CRE", "crh": "CRT", "cri": "CPP",
  "crj": "ECR", "crj": "YCR", "crj": "CRE", "crk": "WCR", "crk": "YCR", "crk": "CRE",
  "crl": "ECR", "crl": "YCR", "crl": "CRE", "crm": "MCR", "crm": "LCR", "crm": "CRE",
  "crp": "CPP", "crs": "CPP", "crx": "CRR", "crx": "ATH", "cs": "CSY", "csa": "CCHN",
  "csh": "QIN", "csj": "QIN", "cso": "CCHN", "csp": "ZHS", "csv": "QIN", "csw": "NCR",
  "csw": "NHC", "csw": "CRE", "csy": "QIN", "ctc": "ATH", "ctd": "QIN", "cte": "CCHN",
  "cth": "QIN", "ctl": "CCHN", "cts": "BIK", "ctu": "MYN", "cu": "CSL", "cuc": "CCHN",
  "cv": "CHU", "cvn": "CCHN", "cwd": "DCR", "cwd": "TCR", "cwd": "CRE", "cy": "WEL",
  "czh": "ZHS", "czo": "ZHS", "czt": "QIN", "da": "DAN", "dao": "QIN", "dap": "NIS",
  "dcr": "CPP", "de": "DEU", "den": "SLA", "den": "ATH", "dep": "CPP", "dgo": "DGO",
  "dgo": "DGR", "dgr": "ATH", "dhd": "MAW", "dib": "DNK", "dik": "DNK", "din": "DNK",
  "dip": "DNK", "diq": "DIQ", "diq": "ZZA", "diw": "DNK", "dje": "DJR", "djk": "CPP",
  "djr": "DJR0", "dks": "DNK", "dng": "DUN", "doi": "DGR", "drh": "MNG", "drw": "DRI",
  "drw": "FAR", "dsb": "LSB", "dty": "NEP", "dup": "MLY", "dv": "DIV", "dv": "DHV",
  "dwk": "KUI", "dwu": "DUJ", "dwy": "DUJ", "dyu": "JUL", "dz": "DZN", "ee": "EWE",
  "ekk": "ETI", "eky": "KRN", "el": "ELL", "emk": "EMK", "emk": "MNK", "emy": "MYN",
  "en": "ENG", "enb": "KAL", "enf": "FNE", "enh": "TNE", "eo": "NTO", "es": "ESP",
  "esg": "GON", "esi": "IPK", "esk": "IPK", "et": "ETI", "eto": "BTI", "eu": "EUQ",
  "eve": "EVN", "evn": "EVK", "ewo": "BTI", "eyo": "KAL", "fa": "FAR", "fab": "CPP",
  "fan": "FAN0", "fan": "BTI", "fat": "FAT", "fat": "AKA", "fbl": "BIK", "ff": "FUL",
  "ffm": "FUL", "fi": "FIN", "fil": "PIL", "fj": "FJI", "flm": "HAL", "flm": "QIN",
  "fmp": "FMP", "fmp": "BML", "fng": "CPP", "fo": "FOS", "fpe": "CPP", "fr": "FRA",
  "fub": "FUL", "fuc": "FUL", "fue": "FUL", "fuf": "FTA", "fuf": "FUL", "fuh": "FUL",
  "fui": "FUL", "fuq": "FUL", "fur": "FRL", "fuv": "FUV", "fuv": "FUL", "fy": "FRI",
  "ga": "IRI", "gaa": "GAD", "gac": "CPP", "gan": "ZHS", "gax": "ORO", "gaz": "ORO",
  "gbm": "GAW", "gce": "ATH", "gcf": "CPP", "gcl": "CPP", "gcr": "CPP", "gd": "GAE",
  "gda": "RAJ", "ggo": "GON", "gha": "BBR", "ghk": "KRN", "gho": "BBR", "gib": "CPP",
  "gil": "GIL0", "gju": "RAJ", "gkp": "GKP", "gkp": "KPL", "gl": "GAL", "gld": "NAN",
  "gn": "GUA", "gnb": "QIN", "gno": "GON", "gnw": "GUA", "gom": "KOK", "goq": "CPP",
  "gox": "BAD0", "gpe": "CPP", "grr": "BBR", "grt": "GRO", "gru": "SOG", "gsw": "ALS",
  "gu": "GUJ", "gug": "GUA", "gui": "GUA", "guk": "GMZ", "gul": "CPP", "gun": "GUA",
  "gv": "MNX", "gwi": "ATH", "gyn": "CPP", "ha": "HAU", "haa": "ATH", "hae": "ORO",
  "hak": "ZHS", "har": "HRI", "hca": "CPP", "he": "IWR", "hea": "HMN", "hi": "HIN",
  "hji": "MLY", "hlt": "QIN", "hma": "HMN", "hmc": "HMN", "hmd": "HMN", "hme": "HMN",
  "hmg": "HMN", "hmh": "HMN", "hmi": "HMN", "hmj": "HMN", "hml": "HMN", "hmm": "HMN",
  "hmp": "HMN", "hmq": "HMN", "hmr": "QIN", "hms": "HMN", "hmw": "HMN", "hmy": "HMN",
  "hmz": "HMN", "hne": "CHH", "hnj": "HMN", "hno": "HND", "ho": "HMO", "ho": "CPP",
  "hoc": "HO ", "hoi": "ATH", "hoj": "HAR", "hoj": "RAJ", "hr": "HRV", "hra": "QIN",
  "hrm": "HMN", "hsb": "USB", "hsn": "ZHS", "ht": "HAI", "ht": "CPP", "hu": "HUN",
  "huj": "HMN", "hup": "ATH", "hus": "MYN", "hwc": "CPP", "hy": "HYE0", "hy": "HYE",
  "hyw": "HYE", "hz": "HER", "ia": "INA", "iby": "IJO", "icr": "CPP", "id": "IND",
  "id": "MLY", "ida": "LUH", "idb": "CPP", "ie": "ILE", "ig": "IBO", "igb": "EBI",
  "ihb": "CPP", "ii": "YIM", "ijc": "IJO", "ije": "IJO", "ijn": "IJO", "ijs": "IJO",
  "ik": "IPK", "ike": "INU", "ikt": "INU", "in": "IND", "in": "MLY", "ing": "ATH",
  "inh": "ING", "io": "IDO", "is": "ISL", "it": "ITA", "itz": "MYN", "iu": "INU",
  "iw": "IWR", "ixl": "MYN", "ja": "JAN", "jac": "MYN", "jak": "MLY", "jam": "JAM",
  "jam": "CPP", "jax": "MLY", "jbe": "BBR", "jbn": "BBR", "jgo": "BML", "ji": "JII",
  "jkm": "KRN", "jkp": "KRN", "jv": "JAV", "jvd": "CPP", "jw": "JAV", "ka": "KAT",
  "kaa": "KRK", "kab": "KAB0", "kab": "BBR", "kam": "KMB", "kar": "KRN", "kbd": "KAB",
  "kby": "KNR", "kca": "KHK", "kca": "KHS", "kca": "KHV", "kcn": "CPP", "kdr": "KRM",
  "kdt": "KUY", "kea": "KEA", "kea": "CPP", "kek": "KEK", "kek": "MYN", "kex": "KKN",
  "kfa": "KOD", "kfr": "KAC", "kfx": "KUL", "kfy": "KMN", "kg": "KON0", "kha": "KSI",
  "khb": "XBD", "khk": "MNG", "kht": "KHT", "kht": "KHN", "ki": "KIK", "kiu": "KIU",
  "kiu": "ZZA", "kj": "KUA", "kjb": "MYN", "kjh": "KHA", "kjp": "KJP", "kjp": "KRN",
  "kjt": "KRN", "kk": "KAZ", "kkz": "ATH", "kl": "GRN", "kln": "KAL", "km": "KHM",
  "kmb": "MBN", "kmr": "KUR", "kmv": "CPP", "kmw": "KMO", "kn": "KAN", "knc": "KNR",
  "kng": "KON0", "knj": "MYN", "knn": "KOK", "ko": "KOR", "ko": "KOH", "koi": "KOP",
  "koi": "KOM", "koy": "ATH", "kpe": "KPL", "kpp": "KRN", "kpv": "KOZ", "kpv": "KOM",
  "kpy": "KYK", "kqs": "KIS", "kqy": "KRT", "kr": "KNR", "krc": "KAR", "krc": "BAL",
  "kri": "KRI", "kri": "CPP", "krt": "KNR", "kru": "KUU", "ks": "KSH", "ksh": "KSH0",
  "kss": "KIS", "ksw": "KSW", "ksw": "KRN", "ktb": "KEB", "ktu": "KON", "ktw": "ATH",
  "ku": "KUR", "kuu": "ATH", "kuw": "BAD0", "kv": "KOM", "kvb": "MLY", "kvl": "KRN",
  "kvq": "KRN", "kvr": "MLY", "kvt": "KRN", "kvu": "KRN", "kvy": "KRN", "kw": "COR",
  "kww": "CPP", "kwy": "KON0", "kxc": "KMS", "kxd": "MLY", "kxf": "KRN", "kxk": "KRN",
  "kxl": "KUU", "kxu": "KUI", "ky": "KIR", "kyu": "KYU", "kyu": "KRN", "la": "LAT",
  "lac": "MYN", "lad": "JUD", "lb": "LTZ", "lbe": "LAK", "lbj": "LDK", "lbl": "BIK",
  "lce": "MLY", "lcf": "MLY", "ldi": "KON0", "lg": "LUG", "li": "LIM", "lif": "LMB",
  "lir": "CPP", "liw": "MLY", "liy": "BAD0", "lkb": "LUH", "lko": "LUH", "lks": "LUH",
  "lld": "LAD", "lmn": "LAM", "ln": "LIN", "lna": "BAD0", "lnl": "BAD0", "lo": "LAO",
  "lou": "CPP", "lri": "LUH", "lrm": "LUH", "lrt": "CPP", "lsm": "LUH", "lt": "LTH",
  "ltg": "LVI", "lto": "LUH", "lts": "LUH", "lu": "LUB", "lus": "MIZ", "lus": "QIN",
  "luy": "LUH", "luz": "LRC", "lv": "LVI", "lvs": "LVI", "lwg": "LUH", "lzh": "ZHT",
  "lzz": "LAZ", "mai": "MTH", "mak": "MKR", "mam": "MAM", "mam": "MYN", "man": "MNK",
  "max": "MLY", "max": "CPP", "mbf": "CPP", "mcm": "CPP", "mct": "BTI", "mdf": "MOK",
  "mdy": "MLE", "men": "MDE", "meo": "MLY", "mfa": "MFA", "mfa": "MLY", "mfb": "MLY",
  "mfe": "MFE", "mfe": "CPP", "mfp": "CPP", "mg": "MLG", "mh": "MAH", "mhc": "MYN",
  "mhr": "LMA", "mhv": "ARK", "mi": "MRI", "min": "MIN", "min": "MLY", "mk": "MKD",
  "mkn": "CPP", "mku": "MNK", "ml": "MAL", "ml": "MLR", "mlq": "MLN", "mlq": "MNK",
  "mmr": "HMN", "mn": "MNG", "mnc": "MCH", "mnh": "BAD0", "mnk": "MND", "mnk": "MNK",
  "mnp": "ZHS", "mns": "MAN", "mnw": "MON", "mo": "MOL", "mod": "CPP", "mop": "MYN",
  "mpe": "MAJ", "mqg": "MLY", "mr": "MAR", "mrh": "QIN", "mrj": "HMA", "ms": "MLY",
  "msc": "MNK", "msh": "MLG", "msi": "MLY", "msi": "CPP", "mt": "MTS", "mtr": "MAW",
  "mud": "CPP", "mui": "MLY", "mup": "RAJ", "muq": "HMN", "mvb": "ATH", "mve": "MAW",
  "mvf": "MNG", "mwk": "MNK", "mwq": "QIN", "mwr": "MAW", "mww": "MWW", "mww": "HMN",
  "my": "BRM", "mym": "MEN", "myq": "MNK", "myv": "ERZ", "mzb": "BBR", "mzs": "CPP",
  "na": "NAU", "nag": "NAG", "nag": "CPP", "nan": "ZHS", "naz": "NAH", "nb": "NOR",
  "nch": "NAH", "nci": "NAH", "ncj": "NAH", "ncl": "NAH", "ncx": "NAH", "nd": "NDB",
  "ne": "NEP", "nef": "CPP", "ng": "NDG", "ngl": "LMW", "ngm": "CPP", "ngo": "SXT",
  "ngu": "NAH", "nhc": "NAH", "nhd": "GUA", "nhe": "NAH", "nhg": "NAH", "nhi": "NAH",
  "nhk": "NAH", "nhm": "NAH", "nhn": "NAH", "nhp": "NAH", "nhq": "NAH", "nht": "NAH",
  "nhv": "NAH", "nhw": "NAH", "nhx": "NAH", "nhy": "NAH", "nhz": "NAH", "niq": "KAL",
  "niv": "GIL", "njt": "CPP", "njz": "NIS", "nkx": "IJO", "nl": "NLD", "nla": "BML",
  "nle": "LUH", "nln": "NAH", "nlv": "NAH", "nn": "NYN", "nn": "NOR", "nnh": "BML",
  "nnz": "BML", "no": "NOR", "nod": "NTA", "npi": "NEP", "npl": "NAH", "nqo": "NKO",
  "nr": "NDB", "nsk": "NAS", "nsu": "NAH", "nue": "BAD0", "nuu": "BAD0", "nuz": "NAH",
  "nv": "NAV", "nv": "ATH", "nwe": "BML", "ny": "CHI", "nyd": "LUH", "nyn": "NKL",
  "oc": "OCI", "oj": "OJB", "ojc": "OJB", "ojg": "OJB", "ojs": "OCR", "ojs": "OJB",
  "ojw": "OJB", "okd": "IJO", "oki": "KAL", "okm": "KOH", "okr": "IJO", "om": "ORO",
  "onx": "CPP", "oor": "CPP", "or": "ORI", "orc": "ORO", "orn": "MLY", "orr": "IJO",
  "ors": "MLY", "ory": "ORI", "os": "OSS", "otw": "OJB", "oua": "BBR", "pa": "PAN",
  "pap": "PAP0", "pap": "CPP", "pbt": "PAS", "pbu": "PAS", "pce": "PLG", "pck": "QIN",
  "pcm": "CPP", "pdu": "KRN", "pea": "CPP", "pel": "MLY", "pes": "FAR", "pey": "CPP",
  "pga": "ARA", "pga": "CPP", "pi": "PAL", "pih": "PIH", "pih": "CPP", "pis": "CPP",
  "pkh": "QIN", "pko": "KAL", "pl": "PLK", "pll": "PLG", "pln": "CPP", "plp": "PAP",
  "plt": "MLG", "pml": "CPP", "pmy": "CPP", "poc": "MYN", "poh": "POH", "poh": "MYN",
  "pov": "CPP", "ppa": "BAG", "pre": "CPP", "prs": "DRI", "prs": "FAR", "ps": "PAS",
  "pse": "MLY", "pst": "PAS", "pt": "PTG", "pub": "QIN", "puz": "QIN", "pwo": "PWO",
  "pwo": "KRN", "pww": "KRN", "qu": "QUZ", "qub": "QWH", "qub": "QUZ", "quc": "QUC",
  "quc": "MYN", "qud": "QVI", "qud": "QUZ", "quf": "QUZ", "qug": "QVI", "qug": "QUZ",
  "quh": "QUH", "quh": "QUZ", "quk": "QUZ", "qul": "QUH", "qul": "QUZ", "qum": "MYN",
  "qup": "QVI", "qup": "QUZ", "qur": "QWH", "qur": "QUZ", "qus": "QUH", "qus": "QUZ",
  "quv": "MYN", "quw": "QVI", "quw": "QUZ", "qux": "QWH", "qux": "QUZ", "quy": "QUZ",
  "qva": "QWH", "qva": "QUZ", "qvc": "QUZ", "qve": "QUZ", "qvh": "QWH", "qvh": "QUZ",
  "qvi": "QVI", "qvi": "QUZ", "qvj": "QVI", "qvj": "QUZ", "qvl": "QWH", "qvl": "QUZ",
  "qvm": "QWH", "qvm": "QUZ", "qvn": "QWH", "qvn": "QUZ", "qvo": "QVI", "qvo": "QUZ",
  "qvp": "QWH", "qvp": "QUZ", "qvs": "QUZ", "qvw": "QWH", "qvw": "QUZ", "qvz": "QVI",
  "qvz": "QUZ", "qwa": "QWH", "qwa": "QUZ", "qwc": "QUZ", "qwh": "QWH", "qwh": "QUZ",
  "qws": "QWH", "qws": "QUZ", "qwt": "ATH", "qxa": "QWH", "qxa": "QUZ", "qxc": "QWH",
  "qxc": "QUZ", "qxh": "QWH", "qxh": "QUZ", "qxl": "QVI", "qxl": "QUZ", "qxn": "QWH",
  "qxn": "QUZ", "qxo": "QWH", "qxo": "QUZ", "qxp": "QUZ", "qxr": "QVI", "qxr": "QUZ",
  "qxt": "QWH", "qxt": "QUZ", "qxu": "QUZ", "qxw": "QWH", "qxw": "QUZ", "rag": "LUH",
  "ral": "QIN", "rbb": "PLG", "rbl": "BIK", "rcf": "CPP", "rif": "RIF", "rif": "BBR",
  "rki": "ARK", "rm": "RMS", "rmc": "ROY", "rmf": "ROY", "rml": "ROY", "rmn": "ROY",
  "rmo": "ROY", "rmw": "ROY", "rmy": "RMY", "rmy": "ROY", "rmz": "ARK", "rn": "RUN",
  "ro": "ROM", "rom": "ROY", "rop": "CPP", "rtc": "QIN", "ru": "RUS", "rue": "RSY",
  "rw": "RUA", "rwr": "MAW", "sa": "SAN", "sah": "YAK", "sam": "PAA", "sc": "SRD",
  "scf": "CPP", "sch": "QIN", "sci": "CPP", "sck": "SAD", "scs": "SCS", "scs": "SLA",
  "scs": "ATH", "sd": "SND", "sdc": "SRD", "sdh": "KUR", "sdn": "SRD", "sds": "BBR",
  "se": "NSM", "seh": "SNA", "sek": "ATH", "sez": "QIN", "sfm": "HMN", "sg": "SGO",
  "sgc": "KAL", "sgw": "CHG", "shi": "SHI", "shi": "BBR", "shl": "QIN", "shu": "ARA",
  "shy": "BBR", "si": "SNH", "siz": "BBR", "sjd": "KSM", "sjo": "SIB", "sjs": "BBR",
  "sk": "SKY", "skg": "MLG", "skr": "SRK", "skw": "CPP", "sl": "SLV", "sm": "SMO",
  "sma": "SSM", "smj": "LSM", "smn": "ISM", "sms": "SKS", "smt": "QIN", "sn": "SNA0",
  "so": "SML", "spv": "ORI", "spy": "KAL", "sq": "SQI", "sr": "SRB", "src": "SRD",
  "srm": "CPP", "srn": "CPP", "sro": "SRD", "srs": "ATH", "ss": "SWZ", "ssh": "ARA",
  "st": "SOT", "sta": "CPP", "stv": "SIG", "su": "SUN", "suq": "SUR", "sv": "SVE",
  "svc": "CPP", "sw": "SWK", "swb": "CMR", "swc": "SWK", "swh": "SWK", "swn": "BBR",
  "swv": "MAW", "syc": "SYR", "ta": "TAM", "taa": "ATH", "taq": "TMH", "taq": "BBR",
  "tas": "CPP", "tau": "ATH", "tcb": "ATH", "tce": "ATH", "tch": "CPP", "tcp": "QIN",
  "tcs": "CPP", "tcy": "TUL", "tcz": "QIN", "tdx": "MLG", "te": "TEL", "tec": "KAL",
  "tem": "TMN", "tez": "BBR", "tfn": "ATH", "tg": "TAJ", "tgh": "CPP", "tgj": "NIS",
  "tgx": "ATH", "th": "THA", "tht": "ATH", "thv": "TMH", "thv": "BBR", "thz": "TMH",
  "thz": "BBR", "ti": "TGY", "tia": "BBR", "tig": "TGR", "tjo": "BBR", "tk": "TKM",
  "tkg": "MLG", "tl": "TGL", "tmg": "CPP", "tmh": "TMH", "tmh": "BBR", "tmw": "MLY",
  "tn": "TNA", "tnf": "DRI", "tnf": "FAR", "to": "TGN", "tod": "TOD0", "toi": "TNG",
  "toj": "MYN", "tol": "ATH", "tor": "BAD0", "tpi": "TPI", "tpi": "CPP", "tr": "TRK",
  "trf": "CPP", "tru": "TUA", "tru": "SYR", "ts": "TSG", "tt": "TAT", "ttc": "MYN",
  "ttm": "ATH", "ttq": "TMH", "ttq": "BBR", "tuu": "ATH", "tuy": "KAL", "tvy": "CPP",
  "tw": "TWI", "tw": "AKA", "txc": "ATH", "txy": "MLG", "ty": "THT", "tyv": "TUV",
  "tzh": "MYN", "tzj": "MYN", "tzm": "TZM", "tzm": "BBR", "tzo": "TZO", "tzo": "MYN",
  "ubl": "BIK", "ug": "UYG", "uk": "UKR", "uki": "KUI", "uln": "CPP", "unr": "MUN",
  "ur": "URD", "urk": "MLY", "usp": "MYN", "uz": "UZB", "uzn": "UZB", "uzs": "UZB",
  "vap": "QIN", "ve": "VEN", "vi": "VIT", "vic": "CPP", "vkk": "MLY", "vkp": "CPP",
  "vkt": "MLY", "vls": "FLE", "vmw": "MAK", "vo": "VOL", "wa": "WLN", "wbm": "WA ",
  "wbr": "WAG", "wbr": "RAJ", "wea": "KRN", "wes": "CPP", "weu": "QIN", "wlc": "CMR",
  "wle": "SIG", "wlk": "ATH", "wni": "CMR", "wo": "WLF", "wry": "MAW", "wsg": "GON",
  "wuu": "ZHS", "xal": "KLM", "xal": "TOD", "xan": "SEK", "xh": "XHS", "xmg": "BML",
  "xmm": "MLY", "xmm": "CPP", "xmv": "MLG", "xmw": "MLG", "xnr": "DGR", "xpe": "XPE",
  "xpe": "KPL", "xsl": "SSL", "xsl": "SLA", "xsl": "ATH", "xst": "SIG", "xup": "ATH",
  "xwo": "TOD", "yaj": "BAD0", "ybb": "BML", "ybd": "ARK", "ydd": "JII", "yi": "JII",
  "yih": "JII", "yo": "YBA", "yos": "QIN", "yua": "MYN", "yue": "ZHH", "za": "ZHA",
  "zch": "ZHA", "zdj": "CMR", "zeh": "ZHA", "zen": "BBR", "zgb": "ZHA", "zgh": "ZGH",
  "zgh": "BBR", "zgm": "ZHA", "zgn": "ZHA", "zh": "ZHS", "zhd": "ZHA", "zhn": "ZHA",
  "zlj": "ZHA", "zlm": "MLY", "zln": "ZHA", "zlq": "ZHA", "zmi": "MLY", "zmz": "BAD0",
  "zne": "ZND", "zom": "QIN", "zqe": "ZHA", "zsm": "MLY", "zu": "ZUL", "zum": "LRC",
  "zyb": "ZHA", "zyg": "ZHA", "zyj": "ZHA", "zyn": "ZHA", "zyp": "QIN", "zzj": "ZHA",
}

def walk(x, fn, fmt, meta):
    if isinstance(x, list):
        a = []
        for i in x:
            if isinstance(i, dict) and 't' in i:
                res = fn(i['t'], i.get('c', None), fmt, meta)
                if res is None:
                    a.append(walk(i, fn, fmt, meta))
                elif isinstance(res, list):
                    for r in res:
                        a.append(walk(r, fn, fmt, meta))
                else:
                    a.append(walk(res, fn, fmt, meta))
            else:
                a.append(walk(i, fn, fmt, meta))
        return a
    elif isinstance(x, dict):
        return {k: walk(v, fn, fmt, meta) for k,v in x.items()}
    else:
        return x

def stringify(x):
    res = []
    def go(key, val, fmt, meta):
        if key in ('Str', 'MetaString'):
            res.append(val)
        elif key in ('Code', 'Math'):
            res.append(val[1])
        elif key in ('LineBreak', 'SoftBreak', 'Space'):
            res.append(" ")
    if isinstance(x, dict) and 't' in x:
        go(x['t'], x.get('c', ""), "", {})
    elif isinstance(x, str):
        return x
    else:
        walk(x, go, "", {})
    return ''.join(res)

def makemd(txt):
    res = []
    for s in re.split(r"(\s)", txt):
        if not len(s):
            continue
        if s == " ":
            res.append({"t": "Space"})
        else:
            res.append({"c": s, "t": "Str"})
    return res

def isTrue(s):
    return s.lower() in ('1', 'true', 'yes')

def process(t, c, fmt, meta):
    if t in ('Span', 'Div'):
        sinfo = c[0]
        if sinfo[0] != "" or len(sinfo[1]):
            return None
        attribs = {i[0]: i[1] for i in sinfo[2]}
        styleattribs = {}
        if 'font' in attribs:
            fval = stringify(attribs['font'])
            if fval.startswith("$"):
                attribs['font'] = meta.get(fval[1:], fval)
            else:
                attribs['font'] = fval
        if fmt in ("html", "commonmark", "markdown_mmd", "markdown_strict"):
            sinfo[2] = []
            if 'font' in attribs or 'feats' in attribs:
                styleattribs = {'font-family': attribs.get("font", meta.get('testfont', ''))}
                newfeats = []
                for feat in attribs.get('feats', '').split():
                    if '=' in feat:
                        (key, val) = feat.split('=')
                    else:
                        (key, val) = (feat, 1)
                    newfeats.append('"{}" {}'.format(key, val))
                if len(newfeats):
                    styleattribs['font-feature-settings'] = ", ".join(newfeats)
            if isTrue(attribs.get('nobreak', "")):
                styleattribs['page-break-inside'] = "avoid"
            if len(styleattribs):
                styleval = "; ".join("{}: {}".format(k, v) for k, v in styleattribs.items() if len(v))
                sinfo[2].append(["style", styleval])
            for k, v in attribs.items():
                if k not in ('font', 'feats', 'nobreak'):
                    sinfo[2].append([k, v])
            return None # since inplace edit
        elif fmt in ("latex", "context", "json"):
            res = {"c": [["", [], []]], "t": t}
            dat = []
            enddat = []
            if 'font' in attribs or 'feats' in attribs:
                font = attribs.get("font", meta.get('testfont', ''))
                size = attribs.get("size", meta.get('testfontsize', 12))
                feats = []
                for feat in attribs.get('feats', "").split():
                    if '=' in feat:
                        (key, val) = feat.split('=')
                        try:
                            intval = int(val)
                        except (TypeError, ValueError):
                            intval = val
                            sys.stderr.write("Found {}\n".format(val))
                    else:
                        (key, intval) = (feat, 1)
                    if intval == 0:
                        feats.append("-{}".format(key))
                    elif isinstance(intval, str):
                        feats.append("{}={}".format(key, intval))
                    else:
                        feats.append("+{}={}".format(key, intval-1))
                lang = attribs.get("lang", "")
                if lang:
                    feats.append("language={}".format(OTLangs.get(lang, lang)))
                dat.append({"c": ["tex", "\\font"], "t": "RawInline"})
                dat.append({"c": ["tex", "\\tempfont"], "t": "RawInline"})
                dat.append({"c": ["tex", '="{}:{}" at {}pt'.format(font, ":".join(feats), size)], "t": "RawInline"})
                #dat.extend(makemd('="{}:{}" at {}pt'.format(font, ":".join(feats), size)))
                dat.append({"c": ["tex", "\\tempfont"], "t": "RawInline"})
                dat.append({"t": "Space"})
            if isTrue(attribs.get('nobreak', "")):
                dat.append({"c": ["tex",
                        r"\catcode`\@=11\let\tempcr\LT@tabularcr"
                        r"\def\LT@tabularcr{\relax\iffalse{\fi\ifnum0=`}\fi"
                        r"\def\crcr{\LT@crcr\noalign{\nobreak}}\let\cr\crcr\LT@t@bularcr}\catcode`\@=12"],
                    "t": "RawBlock" if t == "Div" else "RawInline"})
                enddat.append({"c": ["tex", r"\catcode`\@=11\let\LT@tabularcr\tempcr\catcode`\@=12"],
                            "t": "RawBlock" if t == "Div" else "RawInline"})
            dat.extend(walk(c[1], process, fmt, meta))
            dat.extend(enddat)
            res["c"].append(dat)
            return res

instream = io.TextIOWrapper(sys.stdin.buffer, encoding="utf-8")
source = instream.read()
fmt = sys.argv[1] if len(sys.argv) > 1 else ""
#sys.stderr.write("Format passed = {}\n".format(fmt))
doc = json.loads(source)
if 'meta' in doc:
    meta = {k: stringify(v) for k,v in doc['meta'].items()}

doc['blocks'] = walk(doc['blocks'], process, fmt, meta)
sys.stdout.write(json.dumps(doc))
