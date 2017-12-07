
use "/Users/Putnam_Cole/Dropbox/1_ResearchProjects/1_HarvardProjects/NCDB_HighVolumeCystect/Data/Bladder2004-2013.highvolcyst.dta"

**************
**Covariates**
**************

**Age 
recode AGE (min/50=0 "≤50") (51/60=1 "51-60") (61/70=2 "61-70") (71/80=3 "71-80") (81/90=4 "81-90")(90/max=5 ">90"), gen (age_cat)

**Gender sets 0 as male, 1 as female ******
recode SEX (1=0 Male) (2=1 Female), gen (sex)

**Year of diag 
recode YEAR_OF_DIAGNOSIS (2004/2006=0 first) (2007/2009=1 second) (2010/2012=2 third), gen (year)

**Race 
recode RACE (1=0 white) (2=1 Black) (3/98=2 Other) (99=3 Unknown), gen (race_cat)

**CCI
recode CDCC_TOTAL (0=0 Zero) (1=1 One) (2=2 Two) (else=3 Unknown), gen (CCI)

**Insurance 
recode INSURANCE_STATUS (1=0 Private) (2 4=1 medicaid_other_government) (3=2 medicare) (0=3 not_insured) (else=4 unknown), gen (insurance_cat)

**Incomes
recode MED_INC_QUAR_12 (4 3 =0 High) (2 1=1 Low) (else=3 Unknown), gen (income_cat)

**Education
recode NO_HSD_QUAR_12 (4 3=0 High) (2 1=1 Low) (else=3 Unknown), gen (education_cat)

**County type
recode UR_CD_13 (1 2 3=0 Metro) (4 5 6 7=1 Urban) (8 9=2 Rural) (else=3 unknown), gen(county_cat)

**Great circle 
recode CROWFLY (min/12.4=0 first) (12.5/49.9=1 second) (50/max=2 third)  (else=3 unknown), gen (dist)

**Facility type
recode FACILITY_TYPE_CD (3=0 Academic) (1 2 4=1 Non_Academic) (9=2 unknown), gen (facility_cat)

**Facitity location
recode FACILITY_LOCATION_CD (1 2 3=0 East) (4 5 6 7=1 Center) (8 9=2 West), gen (location_cat)


**********************************
******DISEASE CHARACTERSITICS*****
**********************************

**Histologies
recode HISTOLOGY (8130 8120 = 1 urothelial) (8070 8071 8052 8051 8074 8072 8076 8073 8075 8084 = 2 squamous) (8041 8045 8044 = 3 smallcell) (8131 = 4 micropapillary) (8246 8013 = 5 neuroendocrine) (8490 = 6 signet-ring) (8122 8032 8980 8981 8318 8033 = 7 sarcomatoid) (8140 8480 8260 8310 8481 8255 8323 8574 8144 8261 8263 = 8 adenocarcinoma) (else = .), gen (histology1)
recode histology1 (1=0 urothelial) (2/8=1 non-urothelial) (else=2 unknown), gen (urothelial)


**cMstage
encode TNM_CLIN_M, gen(clinM)
recode clinM (1=0 M0) (2=1 M1) (else=2 unknown), gen (cmstage)

**cNstage
encode TNM_CLIN_N, gen(clinN)
recode clinN (1=0 cN0) (2/4=1 cN+) (else=2 cNx), gen (cnstage)


**cT stage Tumor
encode TNM_CLIN_T, gen(clinT)
recode clinT (1 2 6 15=1 NMIBC) (3 8 9=2 cT2) (4 10 11=3 cT3) (5 12 13=4 cT4) (else=0 unknown), gen (ctstage)
recode ctstage (2=1 cT2) (3 4=2 ≥cT3) (else=.), gen (ctstage2)


*********Identify patients with missing cT/N stage***********

generate missing2=.
replace missing2=0 if cnstage!=2 & ctstage!=5 
replace missing2=1 if cnstage==2 | ctstage==5 | cmstage==2
label define missing2 0 "None missing (cT/N)" 1 "Missing (cT/N/M)"
label values missing2 missing2


************************************************
******Definition of AJCC Stages*****************
************************************************

generate AJCC=.
replace  AJCC=0 if (ctstage==5 | cmstage==2 | cnstage==2)
replace  AJCC=1 if (ctstage==0 & cnstage==0 & cmstage==0)
replace  AJCC=2 if (ctstage==1 & cnstage==0 & cmstage==0)
replace  AJCC=3 if (ctstage==2 | ctstage==3 & cnstage==0 & cmstage==0)
replace  AJCC=4 if ((ctstage==4 & cnstage==0 & cmstage==0)|(cnstage==1)|(cmstage==1))
label define AJCC 0 "Unknown" 1 "AJCC 0+I" 2 "AJCC II" 3 "AJCC III" 4 "AJCC IV"
label values AJCC AJCC AJCC


**************************************************************************************************
******Definition of Surgical TREATMENTS***********************************************************
************************************************************************************************

****>Surgery
recode RX_SUMM_SURG_PRIM_SITE (0=0 none) (50/80=1 cystectomy) (10 11 12 13 14 20 21 22 23 24 25 26 27=2 TURBT) (else=3), gen(surgery)
 
 
 
************************************************************************************************
******LN Count Variable (for possible future analysis******************************************
************************************************************************************************
 
*/gen lncount=REGIONAL_NODES_EXAMINED if REGIONAL_NODES_EXAMINED <=90 & REGIONAL_NODES_EXAMINED>0
*/summarize lncount, detail
*/_pctile lncount, p(50)
*/return list
*/recode lncount (1/14=0 "≤14") (15/90=1 ">14"), gen(lncount_cat)


 
 
**********************************************************************************************
******Drop if Not Cystectomy and Unknown Vital Status******************
**********************************************************************************************

drop if surgery!=1
drop if urothelial!=0
drop if DX_LASTCONTACT_DEATH_MONTHS==0 | DX_LASTCONTACT_DEATH_MONTHS==.

*********************************************************************************************
**** TOTAL ANNUAL FACILITY VOLUME ***********************************************************
*********************************************************************************************

***> Approach according to Rosen et al., PMID: 25443003 (total volume of procedures performed at the treating facility in the year of the patient’s diagnosis, to account for variations in facility volume over time.)


***> Do the following steps in the overall RC population to get the "true" caseload of RCs. Just drop if rc!=1!!!


***> 1. Create string variables/new variables for year of diagnosis, facility ID, and patient ID
gen patientid=PUF_CASE_ID
gen facilityid=PUF_FACILITY_ID
tostring YEAR_OF_DIAGNOSIS, gen (yearstring)


***> 2. Create variable, which combines facility ID and year of diagnosis
gen facilityyear = facilityid + yearstring

***> 3. Save this dataset as "Bladder2004-2013main.dta"

save /Users/Putnam_Cole/Dropbox/1_ResearchProjects/1_HarvardProjects/NCDB_HighVolumeCystect/Data/Bladder2004-2013.highvolcyst.main.dta, replace

***> 4. Create temporary caseload variable
gen caseload=1

***> 5. Collapse caseload variable by combined facility-year-variable
collapse (sum) caseload, by (facilityyear)

*quartiles


xtile meancasequartile=caseload, nquantiles(4)
label define meancasequartile 1 "1st quartile" 2 "2nd quartile" 3 "3rd quartile" 4 "4th quartile" 
label values meancasequartile meancasequartile

*deciles

*/xtile caseloaddecile=caseload, nquantiles(10)
*/label define caseloaddecile 1 "1st decile" 2 "2nd decile" 3 "3rd decile" 4 "4th decile" 5 "5th decile" 6 "6th decile" 7 "7th decile" 8 "8th decile" 9 "9th decile" 10 "10th decile"
*/label values caseloaddecile caseloaddecile

***> 6. Save this new dataset as "Bladder2004-2013temp.dta"

save /Users/Putnam_Cole/Dropbox/1_ResearchProjects/1_HarvardProjects/NCDB_HighVolumeCystect/Data/Bladder2004-2013.highvolcyst.temp.dta, replace 

***> 7. Merge the "main" and "temporary" datasets (this adds the "caseload" variable to the main dataset
use "/Users/Putnam_Cole/Dropbox/1_ResearchProjects/1_HarvardProjects/NCDB_HighVolumeCystect/Data/Bladder2004-2013.highvolcyst.main.dta"
merge m:1 facilityyear using "/Users/Putnam_Cole/Dropbox/1_ResearchProjects/1_HarvardProjects/NCDB_HighVolumeCystect/Data/Bladder2004-2013.highvolcyst.temp.dta"

***> 8. Calculcate mean caseload variable (for annual caseload in each facility) and respective quartiles
******> "Caseload" is the number of radical cystectomies at the facility in the year of the patient's diagnosis. Thus, there are different "caseloads" for one facility and we have to create the "meancaseload", to reach facility-level.

bysort facilityid: egen meancaseload=mean(caseload)

****************Deciles **********************


**************************************
**** Define NAC ********************** 
**************************************

**Chemo (chemo=Nur Mutliagent chemo, chemo1= singel und multiagent chemo***
recode RX_SUMM_CHEMO (0 82 85 86 87=0 no) (3=1 yes_multiple) (else=.), gen (chemo)
recode RX_SUMM_CHEMO (0 82 85 86 87=0 no) (1 2 3=1 yes_sm) (else=.), gen (chemo1)

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
**** Y/N Variable For NAC ********************** 
**************************************

*/generate NAC_YN=.
*/replace NAC_YN=1 if chemoseq==0 | chemoseq==1 
*/replace NAC_YN=0 if chemoseq==2 | chemoseq==3 | chemoseq==. 
*/label define NAC_YN 1 "Yes NAC" 0 "Unknown"


*************************************************************************************
*************Drop if NAC was provided (do after case volume NAC for case volume) ****
*************************************************************************************

drop if chemoseq<=0 

**************************************************************************************************************************************************************************
**Subgroup drop if AJCC IV (drop metastatic disease and drop if unknown vital status ******************************************************************************************************************************************************************************
********************************************************************************************************************************************************************************************
drop if AJCC>=4
drop if YEAR_OF_DIAGNOSIS==2013 
drop if DX_LASTCONTACT_DEATH_MONTHS==0 | DX_LASTCONTACT_DEATH_MONTHS==.


*************************************************
*****Drop everything but top and bottom decile***
*************************************************

*/generate topdecile=.
*/replace topdecile=0 if caseloaddecile==1
*/replace topdecile=1 if caseloaddecile==10 
*/drop if caseloaddecile >=2 & caseloaddecile<=9


*************************************************
*****Summarize the Top and Bottom Deciles***
*************************************************

*/summarize meancaseload if topdecile==0, detail
*/summarize meancaseload if topdecile==1, detail
*/histogram meancaseload if topdecile==0, frequency
*/histogram meancaseload if topdecile==1, frequency
*/tab PUF_FACILITY_ID if topdecile==0
*/tab PUF_FACILITY_ID if topdecile==1


******************************************************************
*****Count the NUmber of Hospitals in the Top and Bottom Decile***
******************************************************************

*/by PUF_FACILITY_ID, sort: gen nvar_topdecile = _n == 1 if topdecile==1
*/count if nvar_topdecile==1



*/by PUF_FACILITY_ID, sort: gen nvar_bottomdecile = _n == 1 if topdecile==0
*/count if nvar_bottomdecile==1

***************************************************
*****Drop everything but top and bottom quartile***
***************************************************

generate topquartile=.
replace topquartile=0 if meancasequartile==1
replace topquartile=1 if meancasequartile==4 
drop if meancasequartile >=2 & meancasequartile<=3
summarize meancaseload if topquartile==0, detail
summarize meancaseload if topquartile==1, detail

*************************************************************************************
*****Generate Histograms for Mean Annual Volume for High and Low Volume Hospitals ***
*************************************************************************************


histogram meancaseload if topquartile==0, frequency
histogram meancaseload if topquartile==1, frequency

******************************************************************
*****Count the NUmber of Hospitals in the Top and Bottom Quartile***
******************************************************************

by PUF_FACILITY_ID, sort: gen nvar_topquartile = _n == 1 if topquartile==1
count if nvar_topquartile==1

by PUF_FACILITY_ID, sort: gen nvar_bottomquartile = _n == 1 if topquartile==0
count if nvar_bottomquartile==1

****************************************************
******Table 1***************************************
****************************************************

***> Median follow-up
stset DX_LASTCONTACT_DEATH_MONTHS, failure(PUF_VITAL_STATUS==1) scale(1)
stsum

svyset, clear

svyset PUF_FACILITY_ID, singleunit(missing)


***> Unqweighted Survival
stset DX_LASTCONTACT_DEATH_MONTHS, failure(PUF_VITAL_STATUS==0)
sts graph, by (topquartile) tmax (100) riskt
sts test topquartile 
stsum, by (topquartile) 
stcox i.topquartile c.AGE i.sex i.race_cat i.CCI i.insurance_cat i.income_cat i.education_cat  i.location_cat i.county_cat i.ctstage 


//IPTW_overall_population

***>Total

logit topquartile  i.age_cat  i.CCI i.education_cat i.income_cat i.insurance_cat SEX/*
*/ i.location_cat i.YEAR_OF_DIAGNOSIS i.ctstage 
predict ptopquartile1 if e(sample)

gen ipw=topquartile/ptopquartile1 + ((1-topquartile)/(1-ptopquartile1))
svyset PUF_FACILITY_ID [pweight=ipw], singleunit(missing)

*USED*

***STEP 1: Choose variables to include into the propensity score.
***Calculate propensity score
pscore topquartile SEX age_cat YEAR_OF_DIAGNOSIS CDCC_TOTAL education_cat income_cat insurance_cat /*
*/ location_cat ctstage facility_cat, pscore(pc_score) blockid(pc_block) detail

***STEP 2: Ensure that propensity score is balanced across treatment and comparison groups.
***Check range of common support (this is just to have look)
psgraph, treated(topquartile) pscore(pc_score)

***STEP 3: Weight sample on propensity score.
***IPTW (creates variable 'iptwt' that stores the weight calculated by this command)
dr DX_LASTCONTACT_DEATH_MONTHS topquartile , ovars (SEX age_cat CDCC_TOTAL education_cat income_cat /*
*/ location_cat ctstage ) pvars (SEX age_cat CDCC_TOTAL education_cat income_cat /*
*/ location_cat ctstage ) genvars

*** Normalize weights to sum to one ('norm_weights')
egen sumofweights = total(ipw)
gen norm_weights = ipw/sumofweights


***STEP 4: Evaluate standardized differences in weighted samples.
*** -pbalchk- gives you stand. diff. and dot plot (by adding 'graph' in the end of the command)
xi: pbalchk topquartile i.SEX i.age_cat i.YEAR_OF_DIAGNOSIS i.CDCC_TOTAL i.education_cat i.income_cat i.insurance_cat /*
*/ i.location_cat i.ctstage, wt(norm_weights) graph





svyset PUF_FACILITY_ID [pweight=norm_weights], singleunit(missing)
stset DX_LASTCONTACT_DEATH_MONTHS [pweight = norm_weights],  failure(PUF_VITAL_STATUS==0) scale(1)


sts graph, by (topquartile) tmax (100) per(100) graphregion(color(white)) bgcolor(white) /*
*/title("Figure 1: Inverse Probability of Treatment Weighting-Adjusted" "Kaplan-Meier Analysis of Overall Survival after Radical Cystectomy" "By Annual Facility Volume in Year of Cystectomy ", span color(black) size(4))  /*
*/yla(,format(%12.0fc)) ytitle("Overall Survival, (%)")/*
*/xtitle("Time (months)")/*
*/legend(order(2 "Top Quartile by Annual Facility Volume in Year of Cystectomy" 1 "Bottom Quartile by Annual Facility Volume in Year of Cystectomy") color(black) ring(0) position(2) rows(2) size(2))





sts test topquartile 
stsum, by (topquartile)
sts list if topquartile==0, at (12 24 36 60)
sts list if topquartile==1, at (12 24 36 60)
stcox topquartile, tvc(topquartile) texp((_t>17))
nlcom (exp(_b[main:topquartile] + _b[tvc:topquartile] ))
nlcom (exp(_b[main:topquartile] + _b[tvc:topquartile] ))-1

svy: mean AGE if topquartile==0 | topquartile==1
estat sd
svy: mean AGE if topquartile==0
estat sd
svy: mean AGE if topquartile==1
estat sd




