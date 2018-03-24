cd "/Users/Putnam_Cole/Dropbox/1_ResearchProjects/1_HarvardProjects/NCDB_RaceContributors/Data/"
use "Bladder2004-2015.race.dta", clear
set more off

**************
**Covariates**
**************

**Age
recode AGE (min/50=0 "≤50") (51/60=1 "51-60") (61/70=2 "61-70") (71/80=3 "71-80") (81/90=4 "81-90") (90/max=5 ">90"), gen (age_cat)

**Gender sets 0 as male, 1 as female ******
recode SEX (1=0 Male) (2=1 Female), gen (sex)

**Year of diagnosis 
recode YEAR_OF_DIAGNOSIS (2004/2006=0 "early") (2007/2009=1 "early mid") (2010/2012=2 "late mid") (2013/2015=3 "late"), gen (year)

**Race 
recode RACE (1=0 white) (2=1 Black) (3/98=2 Other) (99=3 Unknown), gen (race_cat)

**CCI
recode CDCC_TOTAL (0=0 Zero) (1=1 One) (2=2 Two) (3=3 Three_Or_More) (else=4 Unknown), gen (CCI)

**Insurance 
recode INSURANCE_STATUS (1=0 Private) (3=1 medicare) (2 4=2 medicaid_other_government) (0=3 not_insured) (else=4 unknown), gen (payor)

**Incomes
recode MED_INC_QUAR_12 (4 3 =0 High) (2 1=1 Low) (else=3 Unknown), gen (income)

**Education
recode NO_HSD_QUAR_12 (4 3=0 High) (2 1=1 Low) (else=3 Unknown), gen (education)

**Facitity region
recode FACILITY_LOCATION_CD (1 2 3=0 East) (4 5 6 7=1 Center) (8 9=2 West) (else=3 Unknown), gen (region)

**County type
recode UR_CD_13 (1 2 3=0 Metro) (4 5 6 7=1 Urban) (8 9=2 Rural) (else=3 unknown), gen(urban)

**Great circle 
recode CROWFLY (min/12.4=0 first) (12.5/49.9=1 second) (50/max=2 third)  (else=3 unknown), gen (dist)

**Facility type
recode FACILITY_TYPE_CD (3=0 Academic) (1 2 4=1 Non_Academic) (9=2 unknown), gen (facility_cat)

**********************************
******DISEASE CHARACTERSITICS*****
**********************************

**Histologies
recode HISTOLOGY (8130 8120 = 1 uroth) (8070 8071 8052 8051 8074 8072 8076 8073 8075 8084 = 2 squamous) (8041 8045 8044 = 3 smallcell) (8131 = 4 micropapillary) (8246 8013 = 5 neuroendocrine) (8490 = 6 signet-ring) (8122 8032 8980 8981 8318 8033 = 7 sarcomatoid) (8140 8480 8260 8310 8481 8255 8323 8574 8144 8261 8263 = 8 adenocarcinoma) (else = .), gen (histology1)
recode histology1 (1=0 uroth) (2/8=1 non-uroth) (else=2 unknown), gen (uroth)

// Grade 
recode GRADE (1 =0 low_grade) (2 3 4 = 1 high_grade) (else= 2 unknown), gen (tgrade)

**cMstage
encode TNM_CLIN_M, gen(clinM)
recode clinM (2=0 cM0) (3=1 cM+) (else=2 cMx), gen (cmstage)

**cNstage
encode TNM_CLIN_N, gen(clinN)
recode clinN (2=0 cN0) (3/5=1 cN+) (else=2 cNx), gen (cnstage)

**cT stage Tumor
encode TNM_CLIN_T, gen(clinT)
recode clinT (2 14 15=0 cT0aIS) (3=1 cT1) (4 5 6=2 cT2) (7 8 9 10 =3 cT3) (11=4 cT4a) (12=5 cT4b) (else=5 cTx), gen (ctstage)
recode ctstage (0 1=0 NMIBC) (2=1 cT2) (3=2 cT3) (4=3 cT4) (5=4 cTx), gen (ctstage1)

**pMstage
encode TNM_PATH_M, gen(pathM)
recode pathM (2=0 pM0) (3=1 pM+) (else=2 pMx), gen (pmstage)

**pNstage
encode TNM_PATH_N, gen(pathN)
recode pathN (2=0 pN0) (3/5=1 pN+) (else=3 cNx), gen (pnstage)

**pT stage Tumor
encode TNM_PATH_T, gen(pathT)
recode pathT (2 13 14=0 pT0aIS) (3=1 pT1) (4 5 6=2 pT2) (7 8 9 10 =3 cT3) (11=4 cT4a) (12=5 cT4b)  (else=5 unknown), gen (ptstage)
recode ptstage (0 1=0 NMIBC) (2=1 pT2) (3=2 pT3) (4=3 pT4) (5=4 pTx), gen (ptstage1)

*********Identify patients with missing cT/N stage and drop***********

************************************************
******Definition of AJCC Stages*****************
************************************************

generate AJCC=.
replace  AJCC=0 if (ctstage==0 & cmstage!=1 & cnstage!=1)
replace  AJCC=1 if (ctstage==1 & cmstage!=1 & cnstage!=1)
replace  AJCC=3 if (ctstage==2 & cmstage!=1 & cnstage!=1)
replace  AJCC=3 if ((ctstage==3 | ctstage==4) & cmstage!=1 & cnstage!=1)
replace  AJCC=4 if (ctstage==5 | cnstage==1 |cmstage==1)
label define AJCC 0 "AJCC 0" 1 "AJCC I" 2 "AJCC II" 3 "AJCC III" 4 "AJCC IV"
label values AJCC AJCC AJCC

************************************************
******Definition of Surgical TREATMENTS******************
************************************************

****>Surgery
recode RX_SUMM_SURG_PRIM_SITE (0=0 none) (50/80=1 cystectomy) (10 11 12 13 14 20 21 22 23 24 25 26 27=2 TURBT) (else=3), gen(surgery)

 
************************************************
******LN Count Variable (for possible future analysis******************
************************************************
 
gen lncount=REGIONAL_NODES_EXAMINED if REGIONAL_NODES_EXAMINED <=90 & REGIONAL_NODES_EXAMINED>0
summarize lncount, detail
_pctile lncount, p(50)
return list
recode lncount (1/14=0 "≤14") (15/90=1 ">14"), gen(lncount_cat)


**************************************
**** Define NAC ********************** 
**************************************

**Chemo (chemo=Nur Mutliagent chemo, chemo1= singel und multiagent chemo***
recode RX_SUMM_CHEMO (0 82 85 86 87=0 no) (1 2 3=1 yes) (else=3 unknown), gen (chemo)

**Sequence def_surgery-chemo
gen chemodays = DX_DEFSURG_STARTED_DAYS-DX_CHEMO_STARTED_DAYS

gen chemoseq=.
replace chemoseq=0 if chemodays>=0 & chemodays<=180
replace chemoseq=1 if chemodays>=181
replace chemoseq=2 if chemodays>=-180 & chemodays<=-1
replace chemoseq=3 if chemodays==.

label define chemoseq 0 "NAC within 180d" 1 "Delayed RC >180d after NAC" 2 "AC after RC within 180 days" 3 "Unknown"
label values chemoseq chemoseq

**************************************
**** Define Surgery Quality - replaces surgery 
*****with a new categorical variable surg_qual
*********which splits RC into with and without 
*********LND and NAC ********************** 
**************************************

generate surg_qual=.
replace surg_qual=0 if surgery==0
replace surg_qual=1 if surgery==1
replace surg_qual=2 if (surgery==1 & chemoseq==0)
replace surg_qual=3 if (surgery==1 & lncount_cat==1)
replace surg_qual=4 if (surgery==1 & chemoseq==0 & lncount_cat==1)
replace surg_qual=5 if surgery==2 
label define surg_qual 0 "None" 1 "RC alone" 2 "RC with NAC" 3 "RC with LND" 4 "RC with LND+NAC" 5 "TURBT/Local Ablation ONly"
label values surg_qual surg_qual surg_qual

**************************************
**** Define Radiation ********************** 
**************************************

//Radiation therapy
recode RX_SUMM_RADIATION (1/5=1 "radiation") (0=0 noradiation) (9=3 unknown) (else=.), gen (radiation_therapy)

//Radiation limited to bladder
recode RAD_TREAT_VOL (29 34=1 bladder) (else=0), gen(radiation_volume)

//Radiation dose
recode RAD_REGIONAL_DOSE_CGY (1/5899=0 palliative) (5900/9999 59000/88887 =1 definitive) (else=.), gen(radiation_dose)
recode RAD_REGIONAL_DOSE_CGY (1/3899=0 palliative) (3900/9999 39000/88887 =1 definitive) (else=.), gen(radiation_dose1)

//Radiation modality 
recode RAD_REGIONAL_RX_MODALITY (0=0 Norad) (20 =1 rad) (else=3), gen (radiation_modality)


*** defines variables "definitive radiation" which is patients that received a curative dose of pelvic radiation
generate defin_rad=0
replace defin_rad=1 if (radiation_therapy==1 & radiation_dose==1 & radiation_volume==1) 
replace defin_rad=2 if radiation_therapy==3
label define defin_rad 0 "No Definitive Radiation" 1 ">59Gy radiation to Pelvis" 2 "Unknown" 
label values defin_rad defin_rad defin_rad


********************************************************
******Procedure for Calculating Volume******************
********************************************************

***> 1. Create string variables/new variables for year of diagnosis, facility ID, and patient ID
#delimit;
tostring YEAR_OF_DIAGNOSIS, gen (YEAR_STRING);
gen facility_year = PUF_FACILITY_ID + YEAR_STRING;

sort facility_year;
quietly by facility_year:  generate CASELOAD=_N;
xtile qrtile=CASELOAD, nquantiles(4);
label define qrtile 
	1 "1st quartile" 
	2 "2nd quartile" 
	3 "3rd quartile" 
	4 "4th quartile";
label values qrtile qrtile;
la var CASELOAD "Caseload at PUF_FACILITY_ID per year"; 
la var qrtile " Quartile of volume of PUF_FACILITY_ID";

#delimit cr
****************Describe the Quartiles **********************

**** mean caseload in the bottom quartile
summarize CASELOAD if qrtile==1, detail
summarize CASELOAD if qrtile==2, detail
summarize CASELOAD if qrtile==3, detail
summarize CASELOAD if qrtile==4, detail

tab PUF_FACILITY_ID if qrtile==0
tab PUF_FACILITY_ID if qrtile==1


******************************************************************
*****Count the NUmber of Hospitals in the Top and Bottom quartile***
******************************************************************


by PUF_FACILITY_ID, sort: gen nvar_meancaseBOTTOMquartile = _n == 1 if qrtile==1

**** number of hospitals in the bottom quartile ******
count if nvar_meancaseBOTTOMquartile==1

by PUF_FACILITY_ID, sort: gen nvar_meancaseTOPquartile = _n == 1 if qrtile==4


**** number of hospitals in the top quartile ******
count if nvar_meancaseTOPquartile==1

 
**********************************************************************************************
******Drop if Metastatidc, Ta Not Black/White and Unknown Vital Status******************
**********************************************************************************************

* drop if nmibc

drop if ctstage==0 | ctstage==1

* drop if metastatic
drop if AJCC==4

* drop if unknown stage information 
drop if AJCC==.

* drop if unknown information on grade or histology
drop if tgrade==2
drop if uroth==2

***** Drop if unknown surgical treatment

drop if surg_qual==.

*drop if unknown vital status
drop if DX_LASTCONTACT_DEATH_MONTHS==0 | DX_LASTCONTACT_DEATH_MONTHS==.

*drop everything but white and black
drop if race_cat==2 | race_cat==3


**********************************************************************************************
******Survival Analysis******************
**********************************************************************************************

***> Median follow-up
stset DX_LASTCONTACT_DEATH_MONTHS, failure(PUF_VITAL_STATUS==1) scale(1)
stsum
svyset, clear
svyset, singleunit(missing)

***> Unqweighted Survival

stset DX_LASTCONTACT_DEATH_MONTHS, failure(PUF_VITAL_STATUS==0)
sts graph, by (race_cat) tmax (100) riskt
sts test race_cat 
stsum, by (race_cat) 
stcox race_cat


****************************************************************************************
***************IPTW with Demographics ******************
****************************************************************************************

logit race_cat i.age_cat SEX i.region i.urban i.year i.CCI
predict prace_cat0 if e(sample)

gen ipw0=race_cat/prace_cat0 + ((1-race_cat)/(1-prace_cat0))
svyset PUF_FACILITY_ID [pweight=ipw0], singleunit(missing)


***Calculate propensity score
pscore race_cat age_cat SEX region urban year CCI, pscore(pc_score0) blockid(pc_block0) detail

***Check range of common support (this is just to have look)
psgraph, treated(race_cat) pscore(pc_score0)

*** Normalize weights to sum to one ('norm_weights')
egen sumofweights0 = total(ipw0)
gen norm_weights0 = ipw0/sumofweights0


***STEP 4: Evaluate standardized differences in weighted samples.
*** -pbalchk- gives you stand. diff. and dot plot (by adding 'graph' in the end of the command)
xi: pbalchk race_cat i.age_cat SEX i.region i.urban i.year i.CCI, wt(norm_weights0) graph


****************************************************************************************
***************IPTW with Demographics + CCI + Tumor characteristics ******************
****************************************************************************************

logit race_cat i.age_cat SEX i.region i.urban i.year i.CCI i.ctstage i.tgrade i.uroth
predict prace_cat1 if e(sample)

gen ipw1=race_cat/prace_cat1 + ((1-race_cat)/(1-prace_cat1))
svyset PUF_FACILITY_ID [pweight=ipw1], singleunit(missing)


***Calculate propensity score
pscore race_cat age_cat SEX region urban year CCI  ctstage tgrade uroth, pscore(pc_score1) blockid(pc_block1) detail

***Check range of common support (this is just to have look)
psgraph, treated(race_cat) pscore(pc_score1)

*** Normalize weights to sum to one ('norm_weights')
egen sumofweights1 = total(ipw1)
gen norm_weights1 = ipw1/sumofweights1


***STEP 4: Evaluate standardized differences in weighted samples.
*** -pbalchk- gives you stand. diff. and dot plot (by adding 'graph' in the end of the command)
xi: pbalchk race_cat i.age_cat SEX i.region i.urban i.year i.CCI i.ctstage i.tgrade i.uroth, wt(norm_weights1) graph



**************************************************
***************IPTW_by Treatment Variables - Surgery Quality/Type, Radiation, Chemo, High_volume care  *****************
**************************************************

logit race_cat i.age_cat SEX i.region i.urban i.year i.CCI i.ctstage i.tgrade i.uroth i.surg_qual i.chemo i.defin_rad i.qrtile

predict prace_cat2 if e(sample)

gen ipw2=race_cat/prace_cat2 + ((1-race_cat)/(1-prace_cat2))
svyset PUF_FACILITY_ID [pweight=ipw2], singleunit(missing)

***Calculate propensity score
pscore race_cat age_cat SEX region urban year CCI ctstage tgrade uroth surg_qual chemo defin_rad qrtile, pscore(pc_score2) blockid(pc_block2) detail

***Check range of common support (this is just to have look)
psgraph, treated(race_cat) pscore(pc_score2)

*** Normalize weights to sum to one ('norm_weights')
egen sumofweights2 = total(ipw2)
gen norm_weights2 = ipw2/sumofweights2

***STEP 4: Evaluate standardized differences in weighted samples.
*** -pbalchk- gives you stand. diff. and dot plot (by adding 'graph' in the end of the command)
xi: pbalchk race_cat i.age_cat SEX i.region i.urban i.year i.CCI i.ctstage i.tgrade i.uroth i.payor i.income i.education i.surg_qual i.chemo i.defin_rad i.qrtile, wt(norm_weights2) graph


********************************************************************************************************
***************IPTW_by Access Variables: Insurance, Income, Education*****************************************************
********************************************************************************************************

logit race_cat i.age_cat SEX i.region i.urban i.year i.CCI i.ctstage i.tgrade i.uroth i.surg_qual i.chemo i.defin_rad i.qrtile i.payor i.income i.education i.dist
predict prace_cat3 if e(sample)

gen ipw3=race_cat/prace_cat3 + ((1-race_cat)/(1-prace_cat3))
svyset PUF_FACILITY_ID [pweight=ipw3], singleunit(missing)


***Calculate propensity score
pscore race_cat age_cat SEX region urban year CCI  ctstage  tgrade uroth surg_qual chemo defin_rad qrtile payor income education dist, pscore(pc_score3) blockid(pc_block3) detail

***Check range of common support (this is just to have look)
psgraph, treated(race_cat) pscore(pc_score3)

*** Normalize weights to sum to one ('norm_weights')
egen sumofweights3 = total(ipw3)
gen norm_weights3 = ipw3/sumofweights3

*** -pbalchk- gives you stand. diff. and dot plot (by adding 'graph' in the end of the command)
xi: pbalchk race_cat i.age_cat SEX i.region i.urban i.year i.CCI  i.ctstage i.tgrade i.uroth i.surg_qual i.chemo i.defin_rad i.qrtile i.payor i.income i.education i.dist, wt(norm_weights3) graph



*************Cox models unweighted and with each type of weights***********

stset DX_LASTCONTACT_DEATH_MONTHS, failure(PUF_VITAL_STATUS==0) scale(1)
stcox race_cat
stsum, by (race_cat) 
stset DX_LASTCONTACT_DEATH_MONTHS [pweight = norm_weights0],  failure(PUF_VITAL_STATUS==0) scale(1)
stcox race_cat
stsum, by (race_cat) 
stset DX_LASTCONTACT_DEATH_MONTHS [pweight = norm_weights1],  failure(PUF_VITAL_STATUS==0) scale(1)
stcox race_cat
stsum, by (race_cat) 
stset DX_LASTCONTACT_DEATH_MONTHS [pweight = norm_weights2],  failure(PUF_VITAL_STATUS==0) scale(1)
stcox race_cat
stsum, by (race_cat) 
stset DX_LASTCONTACT_DEATH_MONTHS [pweight = norm_weights3],  failure(PUF_VITAL_STATUS==0) scale(1)
stcox race_cat
stsum, by (race_cat) 


*************Table 1 ******************************************


svyset PUF_FACILITY_ID, singleunit(missing)
tab age_cat race_cat, missing col 
tab SEX race_cat, missing col 
tab region race_cat,col missing 
tab urban race_cat, col missing
tab year race_cat, col missing
tab CCI race_cat, col missing
tab ctstage race_cat, col missing
tab tgrade race_cat, col missing
tab uroth race_cat, col missing
tab surg_qual race_cat, col missing
tab chemo race_cat, col missing
tab defin_rad race_cat, missing col 
tab qrtile race_cat, col missing
tab payor race_cat, col missing
tab income race_cat, col missing
tab education race_cat, col missing
tab dist race_cat, col missing


stset DX_LASTCONTACT_DEATH_MONTHS, failure(PUF_VITAL_STATUS==0) scale(1)

xi: pbalchk race_cat i.age_cat
xi: pbalchk race_cat i.SEX
xi: pbalchk race_cat i.region 
xi: pbalchk race_cat i.urban
xi: pbalchk race_cat i.year
xi: pbalchk race_cat i.CCI
xi: pbalchk race_cat i.ctstage
xi: pbalchk race_cat i.tgrade
xi: pbalchk race_cat i.uroth
xi: pbalchk race_cat i.surg_qual
xi: pbalchk race_cat i.chemo
xi: pbalchk race_cat i.defin_rad
xi: pbalchk race_cat i.qrtile
xi: pbalchk race_cat i.payor
xi: pbalchk race_cat i.income
xi: pbalchk race_cat i.education
xi: pbalchk race_cat i.dist


sts test age_cat, trend
sts test SEX
sts test region, trend
sts test urban, trend
sts test year, trend
sts test CCI, trend
sts test ctstage, trend
sts test tgrade
sts test uroth
sts test surg_qual
sts test chemo
sts test defin_rad
sts test qrtile, trend
sts test payor
sts test income
sts test education
sts test dist


*************Table 2 ******************************************

xi: pbalchk race_cat i.age_cat, wt(norm_weights0)
xi: pbalchk race_cat i.SEX, wt(norm_weights0)
xi: pbalchk race_cat i.region, wt(norm_weights0)
xi: pbalchk race_cat i.urban, wt(norm_weights0)
xi: pbalchk race_cat i.year, wt(norm_weights0)
xi: pbalchk race_cat i.CCI, wt(norm_weights0)
xi: pbalchk race_cat i.ctstage, wt(norm_weights0)
xi: pbalchk race_cat i.tgrade, wt(norm_weights0)
xi: pbalchk race_cat i.uroth, wt(norm_weights0)
xi: pbalchk race_cat i.surg_qual, wt(norm_weights0)
xi: pbalchk race_cat i.chemo, wt(norm_weights0)
xi: pbalchk race_cat i.defin_rad, wt(norm_weights0)
xi: pbalchk race_cat i.qrtile, wt(norm_weights0)
xi: pbalchk race_cat i.payor, wt(norm_weights0)
xi: pbalchk race_cat i.income, wt(norm_weights0)
xi: pbalchk race_cat i.education, wt(norm_weights0)
xi: pbalchk race_cat i.dist, wt(norm_weights0)

xi: pbalchk race_cat i.age_cat, wt(norm_weights1)
xi: pbalchk race_cat i.SEX, wt(norm_weights1)
xi: pbalchk race_cat i.region, wt(norm_weights1) 
xi: pbalchk race_cat i.urban, wt(norm_weights1)
xi: pbalchk race_cat i.year, wt(norm_weights1)
xi: pbalchk race_cat i.CCI, wt(norm_weights1)
xi: pbalchk race_cat i.ctstage, wt(norm_weights1)
xi: pbalchk race_cat i.tgrade, wt(norm_weights1)
xi: pbalchk race_cat i.uroth, wt(norm_weights1)
xi: pbalchk race_cat i.surg_qual, wt(norm_weights1)
xi: pbalchk race_cat i.chemo, wt(norm_weights1)
xi: pbalchk race_cat i.defin_rad, wt(norm_weights1)
xi: pbalchk race_cat i.qrtile, wt(norm_weights1)
xi: pbalchk race_cat i.payor, wt(norm_weights1)
xi: pbalchk race_cat i.income, wt(norm_weights1)
xi: pbalchk race_cat i.education, wt(norm_weights1)
xi: pbalchk race_cat i.dist, wt(norm_weights1)


xi: pbalchk race_cat i.age_cat, wt(norm_weights2)
xi: pbalchk race_cat i.SEX, wt(norm_weights2)
xi: pbalchk race_cat i.region, wt(norm_weights2)
xi: pbalchk race_cat i.urban, wt(norm_weights2)
xi: pbalchk race_cat i.year, wt(norm_weights2)
xi: pbalchk race_cat i.CCI, wt(norm_weights2)
xi: pbalchk race_cat i.ctstage, wt(norm_weights2)
xi: pbalchk race_cat i.tgrade, wt(norm_weights2)
xi: pbalchk race_cat i.uroth, wt(norm_weights2)
xi: pbalchk race_cat i.surg_qual, wt(norm_weights2)
xi: pbalchk race_cat i.chemo, wt(norm_weights2)
xi: pbalchk race_cat i.defin_rad, wt(norm_weights2)
xi: pbalchk race_cat i.qrtile, wt(norm_weights2)
xi: pbalchk race_cat i.payor, wt(norm_weights2)
xi: pbalchk race_cat i.income, wt(norm_weights2)
xi: pbalchk race_cat i.education, wt(norm_weights2)
xi: pbalchk race_cat i.dist, wt(norm_weights2)


xi: pbalchk race_cat i.age_cat, wt(norm_weights3)
xi: pbalchk race_cat i.SEX, wt(norm_weights3)
xi: pbalchk race_cat i.region, wt(norm_weights3)
xi: pbalchk race_cat i.urban, wt(norm_weights3)
xi: pbalchk race_cat i.year, wt(norm_weights3)
xi: pbalchk race_cat i.CCI, wt(norm_weights3)
xi: pbalchk race_cat i.ctstage, wt(norm_weights3)
xi: pbalchk race_cat i.tgrade, wt(norm_weights3)
xi: pbalchk race_cat i.uroth, wt(norm_weights3)
xi: pbalchk race_cat i.surg_qual, wt(norm_weights3)
xi: pbalchk race_cat i.chemo, wt(norm_weights3)
xi: pbalchk race_cat i.defin_rad, wt(norm_weights3)
xi: pbalchk race_cat i.qrtile, wt(norm_weights3)
xi: pbalchk race_cat i.payor, wt(norm_weights3)
xi: pbalchk race_cat i.income, wt(norm_weights3)
xi: pbalchk race_cat i.education, wt(norm_weights3)
xi: pbalchk race_cat i.dist, wt(norm_weights3)



***** Graphs ********

stset DX_LASTCONTACT_DEATH_MONTHS [pweight = norm_weights0],  failure(PUF_VITAL_STATUS==0) scale(1)
sts graph, by (race_cat) tmax (100) per(100) graphregion(color(white)) bgcolor(white) /*
*/title("Figure 2A: IPTW-Adjusted Kaplan-Meier Analysis" "of Overall Survival of White and Black Patients Including" "Demographics and Health Status", span color(black) size(4))  /*
*/yla(,format(%12.0fc)) ytitle("Overall Survival, (%)")/*
*/xtitle("Time (months)")/*
*/legend(order(2 "Black patients" 1 "White patients") color(black) ring(0) position(2) rows(2) size(2))


stset DX_LASTCONTACT_DEATH_MONTHS [pweight = norm_weights1],  failure(PUF_VITAL_STATUS==0) scale(1)
sts graph, by (race_cat) tmax (100) per(100) graphregion(color(white)) bgcolor(white) /*
*/title("Figure 2B: IPTW-Adjusted Kaplan-Meier Analysis"  "of Overall Survival of White and Black Patients Including:" "Demographics, Health Status and Tumor Characteristics", span color(black) size(4))  /*
*/yla(,format(%12.0fc)) ytitle("Overall Survival, (%)")/*
*/xtitle("Time (months)")/*
*/legend(order(2 "Black patients" 1 "White patients") color(black) ring(0) position(2) rows(2) size(2))


stset DX_LASTCONTACT_DEATH_MONTHS [pweight = norm_weights2],  failure(PUF_VITAL_STATUS==0) scale(1)
sts graph, by (race_cat) tmax (100) per(100) graphregion(color(white)) bgcolor(white) /*
*/title("Figure 2C: IPTW-Adjusted Kaplan-Meier Analysis" "of Overall Survival of White and Black Patients Including:"  "Demographics, Health Status, Tumor Characteristics, and Treatment", span color(black) size(4))  /*
*/yla(,format(%12.0fc)) ytitle("Overall Survival, (%)")/*
*/xtitle("Time (months)")/*
*/legend(order(2 "Black patients" 1 "White patients") color(black) ring(0) position(2) rows(2) size(2))

stset DX_LASTCONTACT_DEATH_MONTHS [pweight = norm_weights3],  failure(PUF_VITAL_STATUS==0) scale(1)
sts graph, by (race_cat) tmax (100) per(100) graphregion(color(white)) bgcolor(white) /*
*/title("Figure 2D: IPTW-Adjusted Kaplan-Meier Analysis" "of Overall Survival of White and Black Patients Including:" "Demographics, Health Status, Tumor Characteristics," "Treatment, and Access to Care", span color(black) size(4))  /*
*/yla(,format(%12.0fc)) ytitle("Overall Survival, (%)")/*
*/xtitle("Time (months)")/*
*/legend(order(2 "Black patients" 1 "White patients") color(black) ring(0) position(2) rows(2) size(2))








***** END ********



svyset PUF_FACILITY_ID [pweight=norm_weights0], singleunit(missing)
svy: mean AGE if race_cat==0 | race_cat==1
svy: mean AGE if race_cat==1
svy: mean AGE if race_cat==0
pbalchk race_cat AGE, wt(norm_weights)

************age_cat


svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab age_cat race_cat, col
tab age_cat race_cat, col
xi: pbalchk race_cat i.age_cat

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab age_cat race_cat, col
xi: pbalchk race_cat i.age_cat, wt(norm_weights)

************SEX

svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab SEX race_cat, col
tab SEX race_cat, col
xi: pbalchk race_cat i.SEX

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab SEX race_cat, col
xi: pbalchk race_cat i.SEX, wt(norm_weights)

***************RACE


svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab race_cat race_cat, col
tab race_cat race_cat, col
xi: pbalchk race_cat i.race_cat

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab race_cat race_cat, col
xi: pbalchk race_cat i.race_cat, wt(norm_weights)

***************CCI

svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab CCI race_cat, col
tab CCI race_cat, col
xi: pbalchk race_cat i.CCI

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab CCI race_cat, col
xi: pbalchk race_cat i.CCI, wt(norm_weights)

***************Insurance Type

svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab payor race_cat, col
tab payor race_cat, col
xi: pbalchk race_cat i.payor

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab payor race_cat, col
xi: pbalchk race_cat i.payor, wt(norm_weights)

***************Income 

svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab income race_cat, col
tab income race_cat, col
xi: pbalchk race_cat i.income

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab income race_cat, col
xi: pbalchk race_cat i.income, wt(norm_weights)

***************Education Level

svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab education race_cat, col
tab education race_cat, col
xi: pbalchk race_cat i.education

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab education race_cat, col
xi: pbalchk race_cat i.education, wt(norm_weights)

***************region (east, central, western)

svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab region race_cat, col
tab region race_cat, col
xi: pbalchk race_cat i.region

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab region race_cat, col
xi: pbalchk race_cat i.region, wt(norm_weights)

***************Urban-ness (Metro, Urban, Rural)

svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab urban race_cat, col
tab urban race_cat, col
xi: pbalchk race_cat i.urban

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab urban race_cat, col
xi: pbalchk race_cat i.urban, wt(norm_weights)

***************T Stage

svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab ctstage race_cat, col
tab ctstage race_cat, col
xi: pbalchk race_cat i.ctstage

svyset PUF_FACILITY_ID [pweight=norm_weights3], singleunit(missing)
svy: tab ctstage race_cat, col
xi: pbalchk race_cat i.ctstage, wt(norm_weights3)

***************Year of Diagnosis

svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab year race_cat, col
tab year race_cat, col
xi: pbalchk race_cat i.year

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab year race_cat, col
xi: pbalchk race_cat i.year, wt(norm_weights)


svyset PUF_FACILITY_ID [pweight=norm_weights], singleunit(missing)
stset DX_LASTCONTACT_DEATH_MONTHS [pweight = norm_weights],  failure(PUF_VITAL_STATUS==0) scale(1)


sts graph, by (race_cat) tmax (100) per(100) graphregion(color(white)) bgcolor(white) /*
*/title("Figure 1: Inverse Probability of Treatment Weighting-Adjusted" "Kaplan-Meier Analysis of Overall Survival after Radical Cystectomy" "By Annual Facility Volume in Year of Cystectomy ", span color(black) size(4))  /*
*/yla(,format(%12.0fc)) ytitle("Overall Survival, (%)")/*
*/xtitle("Time (months)")/*
*/legend(order(2 "Top Decile by Annual Facility Volume in Year of Cystectomy" 1 "Bottom Decile by Annual Facility Volume in Year of Cystectomy") color(black) ring(0) position(2) rows(2) size(2))



sts test race_cat 
stsum, by (race_cat)
sts list if race_cat==0, at (12 24 36 60)
sts list if race_cat==1, at (12 24 36 60)



