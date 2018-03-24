*******************************************
***********COVARIATES**********************
*******************************************
#delimit ;
set more off;
cd "/Users/Putnam_Cole/Dropbox/1_ResearchProjects/1_HarvardProjects/NCDB_Prostate_RaceContributors/Data";
use "ProstateNCDB.2015.dta", replace;


*** Facilty Case Volume**
#delimit;
tostring YEAR_OF_DIAGNOSIS, gen (yearstring);
gen facilityyear = PUF_FACILITY_ID + yearstring;
save "Propensity_Prostate_main.dta", replace;

gen caseload=1;
collapse (sum) caseload, by (facilityyear);
save "Propensity_Prostate_temp.dta", replace;

use "Propensity_Prostate_main.dta";
merge m:1 facilityyear using "Propensity_Prostate_temp.dta";
drop _merge;

bysort PUF_FACILITY_ID: egen meancaseload=mean(caseload);

*********************************************
******************CO-VARIATES****************
*********************************************

**********************
***DEMOGRAPHICS*******

*******AGE*************
;
recode AGE
	(min/50=0 "<=50") 
	(51/60=1 "51-60") 
	(61/70=2 "61-70") 
	(71/80=3 "71-80") 
	(81/90=4 "81-90") 
	(91/max=5 ">=91"), 
gen (age_cat);

****RACE*******
;
recode RACE 
	(1=0 White) 
	(2=1 Black) 
	(3/99=9 "Other/unknown"), 
gen (race);

**FACILITY LOCATION***
#delimit;
recode FACILITY_LOCATION_CD 
	(1=1 "New England") 
	(2=2 "Middle Atlantic") 
	(3=3 "South Atlantic") 
	(4=4 "East North Central") 
	(5=5 "East South Central") 
	(6=6 "West North Central") 
	(7=7 "West North Central") 
	(8=8 "Mountain") 
	(9=9 "Pacific")
	(else=10 "unknown"), 
gen (location);

***COUNTY*********
;
recode UR_CD_13 
	(1/3=1 Metro) 
	(4/7=2 Urban) 
	(8/9=3 Rural) 
	(else=9 unknown), 
gen (county);


****YEAR OF DIAGNOSIS***
;
recode YEAR_OF_DIAGNOSIS
	(2004 2005 2006=1 "2004-2006")
	(2007 2008 2009=2 "2007-2009")
	(2010 2011 2012=3 "2010-2012")
	(2013 2014 2015=4 "2013-2015"),
gen (year);

*******CCI********
;
recode CDCC_TOTAL 
	(0=0 "0") 
	(1=1 "1") 
	(else=2 ">=02"), 
gen (CCI);

****************************
***TUMOR CHARACTERISTICS****

******PSA********
// CAVE: PSA 98=98+X
;
recode CS_SITESPECIFIC_FACTOR_1
	(980 981 983 985 987 989 990=980)
	(000 988 997 998 999=.),
gen (psa);
gen PSA = (psa/10);

generate psagru=.;
	replace psagru=1 if PSA<10;
	replace psagru=2 if PSA>=10 & PSA<=20;
	replace psagru=3 if PSA>20;
	replace psagru=9 if PSA==.;
label define psagru 1 "PSA<10" 2 "PSA 10-20" 3"PSA>20" 9 "unknown";
label values psagru psagru;


*****GLEASON-SCORE/Needle****
;
recode CS_SITESPECIFIC_FACTOR_8
	(2/6=1 "Gleason <7")
	(7=2 "Gleason 7")
	(8/10=3 "Gleason >7")
    (else=9 "unknown"),
gen (gleason);

***clinical T*********
;
encode TNM_CLIN_T, gen (clinT);
;
recode clinT  
	(3 4 5 6=1 cT1) 
	(7 8 9 10=2 cT2) 
	(11 12 13=3 cT3) 
	(14=4 cT4) 
	(else=9 unknown), 
gen (ctstage);

***clinical N*********
;
encode TNM_CLIN_N, gen (clinN);
recode clinN 
	(2=0 cN0) 
	(3 4=1 cN+) 
	(else=9 unknown), 
gen (cnstage);

***clinical M*********
;
encode TNM_CLIN_M, gen (clinM);
recode clinM 
	(2=0 cM0) 
	(3 4 5 6=1 cM+)  
	(else=9 unknown), 
gen (cmstage);

************************
****HEALTH CARE ACCESS**

******PAYOR*******
;
recode INSURANCE_STATUS 
	(1=0 Private) 
	(3=1 Medicare) 
	(2 4=2 "Medicaid/other government") 
	(0=3 "not insured") 
	(9=9 unknown),
gen (payor);


****INCOME********
;
recode MED_INC_QUAR_12 
	(1=4 "<$38,000") 
	(2=3 "$38,000-$47,999") 
	(3=2 "$48,999-$62,999") 
	(4=1 "$63,000+") 
	(else=9 unknown),
gen (income);

****EDUCATION******
;
recode NO_HSD_QUAR_12 
	(1=1 "highest >21%") 
	(2=2 "13%-20,9%") 
	(3=3 "7-12,9%") 
	(4=4 "lowest <7%") 
	(else=9 "unknown"), 
gen (education);

**Great circle*****
;
recode CROWFLY 
	(min/12.4=0 first) 
	(12.5/49.9=1 second) 
	(50/max=2 third)  
	(else=9 unknown), 
gen (dist);

**************************************
*************TREATMENT****************
**************************************

****SURGERY****
#delimit;
recode RX_SUMM_SURG_PRIM_SITE 
	(0=0 none) 
	(50/80=1 prostatectomy) 
	(else=9 "other/unknown"),
gen (surgery);

***SYSTEMIC TREATMENT W/I 180 DAYS***
;
recode DX_SYSTEMIC_STARTED_DAYS
	(min/180=1 "<=180 days")
	(181/max=2 ">180 days")
	(else=9 unknown),
gen (sytreatd);

***RADIATION***
;
recode RX_SUMM_RADIATION
	(0=0 none)
	(1/5=1 "radiation")
	(else=9 "unknown"),
gen (radiation);

**Treatment**
;
gen treatment=.;
#delimit;
	replace treatment=0 if surgery!=1 & sytreatd!=1 & radiation!=1;
	replace treatment=1 if surgery==1 | radiation==1 | sytreatd==1;
label define treatment 0 "No Treatment/Unknown" 1 "Definitive Treatment";
label value treatment treatment;


***FACILITY CASE VOLUME per YEAR***
#delimit;
xtile mucasecat=caseload, nquantiles(4);
label define mucasecat 1 "1st Quartile" 2 "2nd Quartile" 3 "3rd Quartile" 4 "4th Quratile";
label value mucasecat mucasecat;

**********************
****define cohort*****
**********************

#delimit;
drop if race==9;
drop if ctstage==9; 
drop if cnstage==9;
drop if cmstage==9;
drop if (ctstage==1 | ctstage==2) & (cnstage==0 & cmstage==0);
;

************************
**********DROP**********
************************
#delimit;
drop if DX_LASTCONTACT_DEATH_MONTHS==0 | DX_LASTCONTACT_DEATH_MONTHS==.;
drop if AGE<=40;

save "Cohort_Propensity_Prostate.dta", replace;


********************************************************
************BASELINE CHARACTERISTICS********************
********************************************************
#delimit;
set more off;
tab age_cat race,col chi;
tab location race,col chi;
tab county race,col chi;
tab year race,col chi;
tab CCI race,col chi;
tab ctstage race,col chi;
tab cnstage race,col chi;
tab cmstage race,col chi;
tab psagru race,col chi;
tab gleason race,col chi;
tab surgery race,col chi;
tab radiation race,col chi;
tab sytreatd race,col chi;
tab mucasecat race,col chi;
tab payor race,col chi;
tab income race,col chi;
tab education race,col chi;
tab dist race, col chi;

**************************************
******OUTCOME*************************

*****MEDIAN FOLLOW-UP***
#delimit;
stset DX_LASTCONTACT_DEATH_MONTH, failure (PUF_VITAL_STATUS==1);
stsum;

*********SURVIVAL GENERAL COHORT****
#delimit;
stset DX_LASTCONTACT_DEATH_MONTH, failure (PUF_VITAL_STATUS==0);
stsum;
sts test race;
sts graph, by (race)
	title ("unadjusted Kaplan-Meier")
	tmax(150) 
	xtitle ("Follow-up (months)") 	
		xlabel(0(12)150)
		xmtick(0(12)150) 
	ytitle("Overall Survival, %") 
		ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", angle(horizontal)) 
		ymtick(0(1)1) 
	legend(ring(0) position(2) col(1) bmargin(large))
	risktable(, order(1 "White" 2 "Black") color(black) size(small) rowtitle(, justification(left)) title(, at(rowtitle)));


stsum, by (race);
stcox i.race, cluster (PUF_FACILITY_ID);

******PBALCHK GENERAL COHORT***************
#delimit;
xi:pbalchk race 
	i.age_cat
	i.location
	i.county
	i.year
	i.CCI 
	i.ctstage
	i.cnstage
	i.cmstage
	i.psagru 
	i.gleason
	i.surgery 
	i.radiation
	i.sytreatd
	i.mucasecat
	i.payor
	i.income
	i.education
	i.dist, graph;
************************************************************
***********IPTW********************************************
*********************************************************

***********************
***IPTW DEMOGRAPHICS***
#delimit;
logit (race) 
	i.age_cat 
	i.location 
	i.county 
	i.year 
	i.CCI;
predict prracedem if e(sample),pr;
#delimit;
gen iptwdem=race/prracedem + ((1-race)/(1-prracedem));

*****SURVIVAL weighted for DEMOGRAPHICS********
#delimit;
stset DX_LASTCONTACT_DEATH_MONTH [pweight=iptwdem], failure (PUF_VITAL_STATUS==0);
sts graph, by (race)
	title ("Kaplan-Meier curve adjusted for Demographics")
	tmax(150) 
	xtitle ("Follow-up (months)") 	
		xlabel(0(12)150)
		xmtick(0(12)150) 
	ytitle("Overall Survival, %") 
		ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", angle(horizontal)) 
		ymtick(0(1)1) 
	legend(ring(0) position(2) col(1) bmargin(large))
	risktable(, order(1 "White" 2 "Black") color(black) size(vsmall) rowtitle(, justification(left)) title(, at(rowtitle)));

sts test race;
stsum, by (race);
stcox i.race, cluster (PUF_FACILITY_ID);

****STANDARDIZED DIFF after IPTW for DEMOGRAPHICS****
;
xi:pbalchk race 
	i.age_cat
	i.location
	i.county
	i.year
	i.CCI 
	i.ctstage
	i.cnstage
	i.cmstage
	i.psagru 
	i.gleason
	i.surgery 
	i.radiation
	i.sytreatd
	i.mucasecat
	i.payor
	i.income
	i.education
	i.dist, wt(iptwdem) graph;

****************************************
******IPTW DEMOGRAPHICS plus CANCER*****
#delimit;
logit (race) 
	i.age_cat 
	i.location 
	i.county 
	i.year 
	i.CCI 
	i.ctstage	
	i.cnstage
	i.cmstage
	i.psagru 
	i.gleason;
predict prracecan if e(sample),pr;
#delimit;
gen iptwcan=race/prracecan + ((1-race)/(1-prracecan));

*****SURVIVAL weighted for DEMOGRAPHICS plus CANCER********
#delimit;
stset DX_LASTCONTACT_DEATH_MONTH [pweight=iptwcan], failure (PUF_VITAL_STATUS==0);
sts graph, by (race)
	title ("Kaplan-Meier curve adjusted for Demographics and Cancercharacteristics")
	tmax(150) 
	xtitle ("Follow-up (months)") 	
		xlabel(0(12)150)
		xmtick(0(12)150) 
	ytitle("Overall Survival, %") 
		ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", angle(horizontal)) 
		ymtick(0(1)1) 
	legend(ring(0) position(2) col(1) bmargin(large))
	risktable(, order(1 "White" 2 "Black") color(black) size(vsmall) rowtitle(, justification(left)) title(, at(rowtitle)));

sts test race;
stsum, by (race);
stcox i.race, cluster (PUF_FACILITY_ID);

**STANDARDIZED DIFF for DEMOGRAPHICS plus CANCER********
;
xi:pbalchk race 
	i.age_cat
	i.location
	i.county
	i.year
	i.CCI 
	i.ctstage
	i.cnstage
	i.cmstage
	i.psagru 
	i.gleason
	i.surgery 
	i.radiation
	i.sytreatd
	i.mucasecat
	i.payor
	i.income
	i.education
	i.dist, wt(iptwcan) graph;

********************************************************
******IPTW DEMOGRAPHICS plus CANCER plus TREATMENT******
#delimit;
logit (race) 
	i.age_cat 
	i.location 
	i.county 
	i.year 
	i.CCI 
	i.ctstage	
	i.cnstage
	i.cmstage
	i.psagru 
	i.gleason	
	i.surgery 
	i.radiation
	i.sytreatd;
predict prracetreat if e(sample),pr;
#delimit;
gen iptwtreat=race/prracetreat + ((1-race)/(1-prracetreat));

*****SURVIVAL weighted for DEMOGRAPHICS plus CANCER plus TREATMENT********
#delimit;
stset DX_LASTCONTACT_DEATH_MONTH [pweight=iptwtreat], failure (PUF_VITAL_STATUS==0);
sts graph, by (race)
	title ("Kaplan-Meier curve adjusted for Demographics, Cancercharacteristics and Treatment")
	tmax(150) 
	xtitle ("Follow-up (months)") 	
		xlabel(0(12)150)
		xmtick(0(12)150) 
	ytitle("Overall Survival, %") 
		ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", angle(horizontal)) 
		ymtick(0(1)1) 
	legend(ring(0) position(2) col(1) bmargin(large))
	risktable(, order(1 "White" 2 "Black") color(black) size(vsmall) rowtitle(, justification(left)) title(, at(rowtitle)));

sts test race;
stsum, by (race);
stcox i.race, cluster (PUF_FACILITY_ID);

****STANDARDIZED DIFF after IPTW for DEMOGRAPHICS plus CANCER plus TREATMENT****
#delimit;
xi:pbalchk race 
	i.age_cat
	i.location
	i.county
	i.year
	i.CCI 
	i.ctstage
	i.cnstage
	i.cmstage
	i.psagru 
	i.gleason
	i.surgery 
	i.radiation
	i.sytreatd
	i.mucasecat
	i.payor
	i.income
	i.education
	i.dist
	, wt(iptwtreat) graph;

******IPTW DEMOGRAPHICS plus CANCER no TREATMENT plus ACCESS*****
#delimit;
logit (race) 
	i.age_cat 
	i.location 
	i.county 
	i.year 
	i.CCI 
	i.ctstage	
	i.cnstage
	i.cmstage
	i.psagru 
	i.gleason	
	i.payor
	i.income
	i.education
	i.dist;
predict prraceacc if e(sample),pr;
#delimit;
gen iptwacc=race/prraceacc + ((1-race)/(1-prraceacc));

*****SURVIVAL weighted for DEMOGRAPHICS plus CANCER no TREATMENT plus ACCESS********
#delimit;
stset DX_LASTCONTACT_DEATH_MONTH [pweight=iptwacc], failure (PUF_VITAL_STATUS==0);
sts graph, by (race)
	title ("Kaplan-Meier curve adjusted for Demographics, Cancercharacteristics, Treatment and Access")
	tmax(150) 
	xtitle ("Follow-up (months)") 	
		xlabel(0(12)150)
		xmtick(0(12)150) 
	ytitle("Overall Survival, %") 
		ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", angle(horizontal)) 
		ymtick(0(1)1) 
	legend(ring(0) position(2) col(1) bmargin(large))
	risktable(, order(1 "White" 2 "Black") color(black) size(vsmall) rowtitle(, justification(left)) title(, at(rowtitle)));

sts test race;
stsum, by (race);
stcox i.race, cluster (PUF_FACILITY_ID);

****STANDARDIZED DIFF after IPTW for DEMOGRAPHICS plus CANCER no TREATMENT plus ACCESS****
#delimit;
xi:pbalchk race 
	i.age_cat
	i.location
	i.county
	i.year
	i.CCI 
	i.ctstage
	i.cnstage
	i.cmstage
	i.psagru
	i.gleason
	i.mucasecat
	i.payor
	i.income
	i.education
	i.dist, wt(iptwacc) graph;
#delimit;
save "Propensity_allcalculations.dta",replace;
