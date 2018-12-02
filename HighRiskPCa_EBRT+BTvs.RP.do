
*********************************************
******************COVARIATES*****************
*********************************************

**********************
***DEMOGRAPHICS*******
**********************

****AGE****
recode AGE (min/50=0 "<=50") (51/55=1 "51-55") (56/60=2 "56-60") (61/65=3 "61-65") (66/max=4 ">=65"), gen (age_cat)

****RACE****
recode RACE (1=0 White) (2=1 Black) (3/99=9 "Other/unknown"), gen (race)

****FACILITY LOCATION****
recode FACILITY_LOCATION_CD (1=1 "New England") (2=2 "Middle Atlantic") (3=3 "South Atlantic") (4=4 "East North Central") (5=5 "East South Central") (6=6 "West North Central") (7=7 "West North Central") (8=8 "Mountain") (9=9 "Pacific")(else=10 "unknown"), gen (location)

****COUNTY****
recode UR_CD_13 (1/3=1 Metro) (4/7=2 Urban) (8/9=3 Rural) (else=9 unknown), gen (county)

****YEAR OF DIAGNOSIS****
recode YEAR_OF_DIAGNOSIS (2004 2005 2006 2007 2008 2009=1 "2004-2009")(2010 2011 2012 2013 2014 2015=2 "2010-2015"), gen (year)

*******CCI********
recode CDCC_TOTAL (0=0 "0") (1=1 "1") (else=2 ">=2"), gen (CCI)

******PAYOR*******
recode INSURANCE_STATUS (1=0 Private) (3=1 Medicare) (2 4=2 "Medicaid/other government") (0=3 "not insured") (9=9 unknown), gen (payor)

****INCOME********
recode MED_INC_QUAR_12 (1=4 "<$38,000") (2=3 "$38,000-$47,999") (3=2 "$48,999-$62,999") (4=1 "$63,000+") (else=9 unknown), gen (income)

****EDUCATION******
recode NO_HSD_QUAR_12 (1=1 "highest >21%") (2=2 "13%-20,9%") (3=3 "7-12,9%") (4=4 "lowest <7%") (else=9 "unknown"), gen (education)

**Great circle*****
recode CROWFLY (min/12.4=0 first) (12.5/49.9=1 second) (50/max=2 third)  (else=9 unknown), gen (dist)

****************************
***TUMOR CHARACTERISTICS****
****************************

****PSA****
// CAVE: PSA 98=98+X
recode CS_SITESPECIFIC_FACTOR_1 (980 981 983 985 987 989 990=980) (000 988 997 998 999=.),gen (psa)
gen PSA = (psa/10)

generate psagru=.
	replace psagru=1 if PSA<10
	replace psagru=2 if PSA>=10 & PSA<=20
	replace psagru=3 if PSA>20
	replace psagru=4 if PSA==.
label define psagru 1 "PSA<10" 2 "PSA 10-20" 3"PSA>20" 4 "unknown"
label values psagru psagru

******************************************
****Gleason Score from Biopsy or TUR-P****
******************************************

recode CS_SITESPECIFIC_FACTOR_6 (002/006=0) (007=1) (008=2) (009=3) (010=4) (else=5) if year==1, gen (gleasonscore0)
generate GS0=.
replace GS0=0 if gleasonscore0==0
replace GS0=1 if gleasonscore0==1
replace GS0=2 if gleasonscore0==2
replace GS0=3 if gleasonscore0==3
replace GS0=4 if gleasonscore0==4
replace GS0=5 if gleasonscore0==5
label define GS0 0 "GS≤6" 1 "GS7" 2 "GS8" 3 "GS9" 4 "GS10" 5 "unknown" 
label values GS0 GS0

recode CS_SITESPECIFIC_FACTOR_7 (011/024 029 031/033 039 041 042 049 051 059=0 "Gleason<=6")(034=1 "Gleason 3+4")(43=2 "Gleason 4+3")(025 052=3 "Other Gleason 7")(044=4 "Gleason 4+4")(035=5 "Gleason 3+5")(053=6 "Gleason 5+3")(045=7 "Gleason 4+5")(054=8 "Gleason 5+4")(055=9 "Gleason 5+5")(else=10 unknown) if year==2, gen (GleasonScore)
gen gleasonsum=.
replace gleasonsum=0 if GleasonScore==0
replace gleasonsum=1 if GleasonScore==1 | GleasonScore==2 | GleasonScore==3
replace gleasonsum=2 if GleasonScore==4 | GleasonScore==5 | GleasonScore==6
replace gleasonsum=3 if GleasonScore==7 | GleasonScore==8
replace gleasonsum=4 if GleasonScore==9
replace gleasonsum=5 if GleasonScore==10  
label define gleasonsum 0 "<=6" 1 "GS 7" 2 "GS 8" 3 "GS 9" 4 "GS 10" 5 "else/unknown"
label values gleasonsum gleasonsum 

generate GSall=.
replace GSall=0 if (GS0==0 | gleasonsum==0)
replace GSall=1 if (GS0==1 | gleasonsum==1)
replace GSall=2 if (GS0==2 | gleasonsum==2)
replace GSall=3 if (GS0==3 | gleasonsum==3)
replace GSall=4 if (GS0==4 | gleasonsum==4)
replace GSall=5 if (GS0==5 | gleasonsum==5)
label define GSall 0 "<=6" 1 "GS 7" 2 "GS 8" 3 "GS 9" 4 "GS 10" 5 "else/unknown"
label values GSall GSall 

****clinical T****
encode TNM_CLIN_T, gen (clinT)
recode clinT (2=0 "cT0") (3 4 5 6=1 "cT1") (7 8 9 10=2 "cT2") (11 12 13=3 "cT3") (14=4 "cT4") (else=5 "unknown"), gen (cTstage)

****clinical N****
encode TNM_CLIN_N, gen (clinN)
recode clinN (2=0 cN0) (3 4=1 cN+) (else=9 unknown),gen (cnstage)

****clinical M****
encode TNM_CLIN_M, gen (clinM)
recode clinM  (2=0 cM0) (3 4 5 6=1 cM+) (else=9 unknown),gen (cmstage)

**************************
******TREATMENT***********
**************************

****Surgery****
recode RX_SUMM_SURG_PRIM_SITE (0=0 none) (50/80=1 prostatectomy) (else=2 "other/unknown"),gen (surgery)

****Radiatio****
recode RX_SUMM_RADIATION (0=0 none) (1=1 "beam radiation") (2=2 brachytherapy) (3=3 radioisotopes) (4=4 "combination of 1 with 2 and/or 3") (else=5 unknown), gen (radiatio)

**** RP vs. RX ****
gen RP_RX=.
replace RP_RX=0 if surgery==1 & (radiatio==0 | radiatio==5)
replace RP_RX=1 if surgery==1 & (radiatio==1 | radiatio==2 | radiatio==3 |radiatio==4)
replace RP_RX=2 if surgery!=1 & (radiatio==1 | radiatio==2 | radiatio==3 |radiatio==4)
replace RP_RX=3 if surgery!=1 & (radiatio==0 | radiatio==5)
label define RP_RX 0 "RP only" 1 "RP+RX" 2 "RX only" 3 "no RP, no RX" 
label values RP_RX RP_RX

**** Sequence of RP and RX ****
gen sequence=.
replace sequence=0 if RP_RX==1 & DX_DEFSURG_STARTED_DAYS<DX_RAD_STARTED_DAYS 
replace sequence=1 if RP_RX==1 & DX_DEFSURG_STARTED_DAYS>DX_RAD_STARTED_DAYS
replace sequence=2 if RP_RX==1 & (DX_DEFSURG_STARTED_DAYS==. | DX_RAD_STARTED_DAYS==. | DX_RAD_STARTED_DAYS==DX_DEFSURG_STARTED_DAYS)
label define sequence 0 "RP first" 1 "RX first" 2 "unknown sequence" 
label values sequence sequence

**** RX regions ****
**** Region of RX interest ****
recode RAD_TREAT_VOL (0=0 "none") (29 34 35 41 60=1 "region of interest") (else=2 "unknown/else"), gen (RX_regions)

**** anyRX ****
gen anyRX=.
replace anyRX=0 if radiatio==1 | radiatio==2 | radiatio==3 |radiatio==4
replace anyRX=1 if radiatio==0 | radiatio==5
label define anyRX 0 "RX" 1 "no RX"
label value anyRX anyRX

**** RX at region of interest ****
gen RX=.
replace RX=0 if anyRX==0 & RX_regions==1
replace RX=1 if anyRX==0 & (RX_regions==0 | RX_regions==2)
replace RX=2 if anyRX==1 & (RX_regions==0 | RX_regions==2 | RX_regions==1) 
label define RX 0 "RX of region of interest" 1 "RX, but none/unknown/elsewhere region of interest" 2 "no RX, but region of interest"
label values RX RX

**** EBRT vs. EBRT + brachytherapy ****
gen RTX=.
replace RTX=0 if RX==0 & radiatio==1
replace RTX=1 if RX==0 & radiatio==4
replace RTX=2 if RX==0 & radiatio==2
replace RTX=3 if RX==0 & radiatio==3
replace RTX=4 if RX==0 & radiatio==5
label define RTX 0 "EBRT" 1 "EBRT+BT" 2 "BT" 3 "radioisotopes" 4 "else"
label value RTX RTX 

***************************************************
**** Definition of final treatment cohorts ****
***************************************************

gen cohorts=.
replace cohorts=0 if RP_RX==0 
replace cohorts=1 if RP_RX==1 & sequence==0
replace cohorts=2 if RP_RX==2 & RTX==0 
replace cohorts=3 if RP_RX==1 & sequence==1 & RTX==1 
replace cohorts=4 if RP_RX==1 & sequence==1 & RTX==0 
replace cohorts=5 if RP_RX==2 & RTX==1 
replace cohorts=6 if RP_RX==1 & sequence==2 
label define cohorts 0 "RP only" 1 "RP+RTX" 2 "EBRT alone" 3 "RTX+RP" 4 "EBRT+RP" 5 "EBRT+BT only" 6 "both RP/RTX, unknown sequence"
label value cohorts cohorts 

gen cohort=.
replace cohort=0 if cohorts==0 | cohorts==1
replace cohort=1 if cohorts==5 | cohorts==3
label define cohort 0 "RP" 1 "EBRT+BT"
label value cohort cohort 

***************************************************
**** Definition of androgen deprivation therapy****
***************************************************

gen ADT=.
replace ADT=0 if RX_SUMM_HORMONE==01
replace ADT=1 if RX_SUMM_HORMONE!=01 
label define ADT 0 "ADT" 1 "no ADT"
label value ADT ADT

***************************************************
**** Definition of high-risk patients ****
***************************************************

gen hr=. 
replace hr=0 if cTstage==3 | cTstage==4 | GSall==2 | GSall==3 | GSall==4 | psagru==3
labe define hr 0 "high-risk"
label value hr 

****************************************
********* Define cohort - DROP *********
****************************************

**** year of diagnosis 2010 - 2015 ****
drop if year==2

**** only ≤ 65 ****
drop if AGE>=66

**** Exlcusion of patients with other histology ****
drop if HISTOLOGY!=8140 

**** exclude unknown and cT0 ****
drop if cTstage==0
drop if cTstage==5 

**** only cNO ****
drop if cnstage!=0

**** only cM0 ****
drop if cmstage!=0 

*** unknown PSA ***
drop if psagru==4

*** unknwon GS *** 
drop if GSall==5

**** only CCI ****
drop if CCI!=0

**** drop if non high-risk **** 
drop if hr!=0 

**** exlcusion of radiation other than EBRT ****
drop if radiatio==5
drop if radiatio==2 
drop if radiatio==3
drop if cohorts==2
drop if cohorts==4
drop if sequence==2

**** drop if insufficient radiation dose administered (<40Gy) ****
drop if RX_regions==2
drop if RAD_REGIONAL_DOSE_CGY<4000 & RAD_BOOST_DOSE_CGY==88888 & cohort==1
drop if RAD_BOOST_DOSE_CGY<4000 & RAD_REGIONAL_DOSE_CGY==88888 & cohort==1
drop if RAD_REGIONAL_DOSE_CGY<4000 & RAD_BOOST_DOSE_CGY==88888 & cohort==0
drop if RAD_BOOST_DOSE_CGY<4000 & RAD_REGIONAL_DOSE_CGY==88888 & cohort==0

**** surgery unknown/other ****
drop if surgery==2 

**** other treatment ***
drop if RP_RX==3

**** unknown vital status or lost of follow-up ****
drop if DX_LASTCONTACT_DEATH_MONTHS==0 | DX_LASTCONTACT_DEATH_MONTHS==.

********************************************************
************ Results ***********************************
********************************************************

*****************
**** IPTW  ****
*****************

logit cohort i.age_cat i.race i.payor i.income i.education i.GSall i.psagru i.cTstage i.dist i.county
predict pcohort1 if e(sample)

gen ipw=cohort/pcohort1 + ((1-cohort)/(1-pcohort1))
svyset PUF_FACILITY_ID [pweight=ipw], singleunit(missing)

***STEP 1: Choose variables to include into the propensity score.
***Calculate propensity score
*pscore cohort age_cat race payor income education GSall psagru cTstage dist county, pscore(pc_score) blockid(pc_block) detail

***STEP 2: Ensure that propensity score is balanced across treatment and comparison groups.
***Check range of common support (this is just to have look)
*psgraph, treated (cohort) pscore(pc_score)

***STEP 3: Weight sample on propensity score.
***IPTW (creates variable 'iptwt' that stores the weight calculated by this command)
*dr DX_LASTCONTACT_DEATH_MONTHS cohort, ovars (age_cat race payor income education GSall psagru cTstage dist county) pvars (age_cat race payor income education GSall psagru cTstage dist county) genvars

*** Normalize weights to sum to one ('norm_weights')
egen sumofweights = total(ipw)
gen norm_weights= ipw/sumofweights

***STEP 4: Evaluate standardized differences in weighted samples.
*** -pbalchk- gives you stand. diff. and dot plot (by adding 'graph' in the end of the command)
xi: pbalchk cohort i.age_cat i.race i.payor i.income i.education i.GSall i.psagru i.cTstage i.dist i.county, wt(norm_weights) graph

**************************************
**** Baseline characteristics ****
**************************************

*count if RAD_REGIONAL_DOSE_CGY<4000 & RAD_BOOST_DOSE_CGY==88888 & cohort==1
*count if RAD_REGIONAL_DOSE_CGY>5040 & RAD_BOOST_DOSE_CGY==88888 & cohort==1
*count if RAD_BOOST_DOSE_CGY<4000 & RAD_REGIONAL_DOSE_CGY==88888 & cohort==1
*count if RAD_BOOST_DOSE_CGY>5040 & RAD_REGIONAL_DOSE_CGY==88888 & cohort==1
*count if RAD_REGIONAL_DOSE_CGY<4000 & RAD_BOOST_DOSE_CGY==88888 & cohort==0
*count if RAD_REGIONAL_DOSE_CGY>5040 & RAD_BOOST_DOSE_CGY==88888 & cohort==0
*count if RAD_BOOST_DOSE_CGY<4000 & RAD_REGIONAL_DOSE_CGY==88888 & cohort==0
*count if RAD_BOOST_DOSE_CGY>5040 & RAD_REGIONAL_DOSE_CGY==88888 & cohort==0

*count if RAD_REGIONAL_DOSE_CGY>=4000 & RAD_REGIONAL_DOSE_CGY<=5040 & RAD_BOOST_DOSE_CGY==88888 & cohort==0
*count if RAD_BOOST_DOSE_CGY>=4000 & RAD_BOOST_DOSE_CGY<=5040 & RAD_REGIONAL_DOSE_CGY==88888 & cohort==0
*count if RAD_REGIONAL_DOSE_CGY>=4000 & RAD_REGIONAL_DOSE_CGY<=5040 & RAD_BOOST_DOSE_CGY==88888 & cohort==1
*count if RAD_BOOST_DOSE_CGY>=4000 & RAD_BOOST_DOSE_CGY<=5040 & RAD_REGIONAL_DOSE_CGY==88888 & cohort==1


**** Median follow-up ****
stset DX_LASTCONTACT_DEATH_MONTHS, failure(PUF_VITAL_STATUS==1) scale(1) 
stsum, by (cohort)

**** Descriptive table ****

****age
svyset PUF_FACILITY_ID, singleunit(missing)
svy: mean AGE if cohort==0 | cohort==1
svy: mean AGE if cohort==1
svy: mean AGE if cohort==0
xi: pbalchk cohort AGE

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: mean AGE if cohort==0 | cohort==1
svy: mean AGE if cohort==1
svy: mean AGE if cohort==0
pbalchk cohort AGE, wt(norm_weights)

****age_cat
svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab age_cat cohort, col
tab age_cat cohort, col
xi: pbalchk cohort i.age_cat

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab age_cat cohort, col
xi: pbalchk cohort i.age_cat, wt(norm_weights)

****race
svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab race cohort, col
tab race cohort, col
xi: pbalchk cohort i.race

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab race cohort, col
xi: pbalchk cohort i.race, wt(norm_weights)

****Insurance Type
svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab payor cohort, col
tab payor cohort, col
xi: pbalchk cohort i.payor

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab payor cohort, col
xi: pbalchk cohort i.payor, wt(norm_weights)

****Income 
svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab income cohort, col
tab income cohort, col
xi: pbalchk cohort i.income

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab income cohort, col
xi: pbalchk cohort i.income, wt(norm_weights)

****Education Level
svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab education cohort, col
tab education cohort, col
xi: pbalchk cohort i.education

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab education cohort, col
xi: pbalchk cohort i.education, wt(norm_weights)

**** Gleason Score  
svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab GSall cohort, col
tab GSall cohort, col
xi: pbalchk cohort i.GSall

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab GSall cohort, col
xi: pbalchk cohort i.GSall, wt(norm_weights)

**** PSA
svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab psagru cohort, col
tab psagru cohort, col
xi: pbalchk cohort i.psagru

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab psagru cohort, col
xi: pbalchk cohort i.psagru, wt(norm_weights)

**** clinical T stage
svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab cTstage cohort, col
tab cTstage cohort, col
xi: pbalchk cohort i.cTstage

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab cTstage cohort, col
xi: pbalchk cohort i.cTstage, wt(norm_weights)

**** Distance from hospital 
svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab dist cohort, col
tab dist cohort, col
xi: pbalchk cohort i.dist

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab dist cohort, col
xi: pbalchk cohort i.dist, wt(norm_weights)

**** County
svyset PUF_FACILITY_ID, singleunit(missing)
svy: tab county cohort, col
tab county cohort, col
xi: pbalchk cohort i.county

svyset PUF_FACILITY_ID [pweight=norm_weight], singleunit(missing)
svy: tab county cohort, col
xi: pbalchk cohort i.county, wt(norm_weights)

*****************************************************************
**** Adjusted Kaplan-Meier curves + Cox regression analyses  ****
*****************************************************************

svyset PUF_FACILITY_ID [pweight=norm_weights], singleunit(missing)
stset DX_LASTCONTACT_DEATH_MONTHS [pweight = norm_weights],  failure(PUF_VITAL_STATUS==0) scale(1)
sts graph, by (cohort) tmax (200) per (100) legend(order(2 "EBRT+BT" 1 "RP") color(black) ring(0) position(0) rows(2) size(2))

sts test cohort
stcox cohort
stsum, by (cohort)
sts list if cohort==0, at (12 24 36 60)
sts list if cohort==1, at (12 24 36 60)
sts list if cohort==0, at (96 108 120)
sts list if cohort==1, at (96 108 120)

sts list if cohort==0, at (60 120 142) 
sts list if cohort==1, at (60 120 142)


stcox i.cohort
*stcox i.cohort i.age_cat i.race i.payor i.income i.education i.GSall i.psagru i.cTstage i.dist i.county ** nicht notwendig, weil bereits in dem weighting berücksichtigt 

**> Test of proportional-hazards assumption
estat phtest

**** Adjusted median overall survival time ****
stset DX_LASTCONTACT_DEATH_MONTHS,  failure(PUF_VITAL_STATUS==0) scale(1)
stsum, by (cohort)

****************************************************
**Subgroup analysis for the reviewer's comments ****
****************************************************

* The idea is to create a new time variable looking at 5 years, 10 years and end of follow-up as 
*well as a new variable for the vital status specifically at this given time. Afterwards, we 
*can re-run the regular KM and Cox regression analyses * 

*** 5 years ****

gen time=DX_LASTCONTACT_DEATH_MONTHS
replace time=60 if DX_LASTCONTACT_DEATH_MONTHS>=60 

gen vital=PUF_VITAL_STATUS
replace vital=1
replace vital=0 if PUF_VITAL_STATUS==0 & DX_LASTCONTACT_DEATH_MONTHS<=60

svyset PUF_FACILITY_ID [pweight=norm_weights], singleunit(missing)
stset time [pweight = norm_weights],  failure(vital==0) scale(1)
sts graph, by (cohort) tmax (200) per (100) legend(order(2 "EBRT+BT" 1 "RP") color(black) ring(0) position(0) rows(2) size(2))
sts test cohort			
stcox i.cohort							

*** 10 years 
gen time1=DX_LASTCONTACT_DEATH_MONTHS
replace time1=120 if DX_LASTCONTACT_DEATH_MONTHS>=120 

gen vital1=PUF_VITAL_STATUS
replace vital1=1
replace vital1=0 if PUF_VITAL_STATUS==0 & DX_LASTCONTACT_DEATH_MONTHS<=120

svyset PUF_FACILITY_ID [pweight=norm_weights], singleunit(missing)
stset time1 [pweight = norm_weights],  failure(vital1==0) scale(1)
sts graph, by (cohort) tmax (200) per (100) legend(order(2 "EBRT+BT" 1 "RP") color(black) ring(0) position(0) rows(2) size(2))
sts test cohort			
stcox i.cohort
							
*** last follow-up	(based on the EBRT+BT group) *** 
gen time2=DX_LASTCONTACT_DEATH_MONTHS
replace time2=142 if DX_LASTCONTACT_DEATH_MONTHS>=142 

gen vital2=PUF_VITAL_STATUS
replace vital2=1
replace vital2=0 if PUF_VITAL_STATUS==0 & DX_LASTCONTACT_DEATH_MONTHS<=142

svyset PUF_FACILITY_ID [pweight=norm_weights], singleunit(missing)
stset time2 [pweight = norm_weights],  failure(vital2==0) scale(1)
sts graph, by (cohort) tmax (200) per (100) legend(order(2 "EBRT+BT" 1 "RP") color(black) ring(0) position(0) rows(2) size(2))
sts test cohort			
stcox i.cohort


************************************************
**Subgroup analysis for re-resubmission ********
************************************************

		
svyset PUF_FACILITY_ID [pweight=norm_weights], singleunit(missing)
stset DX_LASTCONTACT_DEATH_MONTHS [pweight = norm_weights],  failure(PUF_VITAL_STATUS==0) scale(1)
sts graph, by (cohort) tmax (120) per (100) legend(order(2 "EBRT+BT" 1 "RP") color(black) ring(0) position(0) rows(2) size(2))

