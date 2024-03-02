***The following lines estimates and graphs Kernel Density of each variables***
**This file is a replication of Hsieh, Moretti(2019), modified for the project**
********************************************************************************
*EMP****************************************************************************
********************************************************************************
********************************************************************************
clear all
set more off

* Load Data
import delimited "/Users/peter/Library/CloudStorage/OneDrive-UW-Madison/Hsieh, Moretti/task/Replication Combined/output/data_julia3.csv"
cd "/Users/peter/Library/CloudStorage/OneDrive-UW-Madison/Hsieh, Moretti/task/Replication Combined/output"


gen logemp1964 = log(emp1964)
gen logemp2009 = log(emp2009)
gen logemp2019 = log(emp2019)

egen meanlogemp64 = mean(logemp1964) 
g dm_emp64 = logemp1964 - meanlogemp64

egen meanlogemp09 = mean(logemp2009)
g dm_emp09 = logemp2009 - meanlogemp09

egen meanlogemp19 = mean(logemp2019)
g dm_emp19 = logemp2019 - meanlogemp19

*EMP64,09,19
twoway (kdensity dm_emp64, bwidth(0.2))(kdensity dm_emp09, bwidth(0.2)lpattern(dash))(kdensity dm_emp19, bwidth(0.2) lpattern(dash_dot)),legend(label(1 "1964") label(2 "2009") label(3 "2019") region(lwidth(none)) pos(2) ring(0)) graphregion(color(white)) bgcolor(white) xtitle("Employment")saving(employment19, replace)
graph export employment19.eps, replace logo(off)

*EMP64,09,
kdensity emp64 , legend(region(lwidth(none))) graphregion(color(white)) bgcolor(white) addplot(kdensity emp09 ,  lpattern(--) ) title("Spatial Distribution of Employment") bwidth(0.3) ytitle(" ") xtitle("Employment") note(" ") caption(" ") legend(label(1 "1964") label(2 "2009")  pos(2) ring(0)) saving(employment, replace)
graph export employment.eps, replace logo(off)



********************************************************************************
*Wage***************************************************************************
********************************************************************************
********************************************************************************
clear all
set more off

* Load Data
import delimited "/Users/peter/Library/CloudStorage/OneDrive-UW-Madison/Hsieh, Moretti/task/task3_Resdualize_MSA_Wage/output/pivot64_19.csv"
cd "/Users/peter/Library/CloudStorage/OneDrive-UW-Madison/Hsieh, Moretti/task/task6_Replicate_Wage/output"

**********************
*Weighted Conditional*
**********************
g ww64 = round(emp1964)
g ww09 = round(emp2009)
g ww19 = round(emp2019)

**reswage is residualized wage
g dm_reswage64 = reswage1964 - meanreswage1964
g dm_reswage09 = reswage2009 - meanreswage2009
g dm_reswage19 = reswage2019 - meanreswage2019

*KDE64,09
kdensity dm_reswage64 [weight = ww64], legend(region(lwidth(none))) graphregion(color(white)) bgcolor(white)  bwidth(0.04) addplot(kdensity dm_reswage09 [weight = ww09],  lpattern(--) bwidth(0.04)) title("Weighted, Conditional") ytitle(" ") xtitle("Wage") xlabel(-.5 0 .5) xscale(r(-.6 .6)) ylabel(0 1 2 3 4 5)  note(" ") caption(" ") legend(label(1 "1964")   label(2 "2009")  position(2) ring(0)  ) saving(conditional, replace)
graph export conditional.eps, replace logo(off)

*KDE64,09,19
twoway (kdensity dm_reswage64, bwidth(0.05)) ///
       (kdensity dm_reswage09, bwidth(0.05) lpattern(dash)) ///
       (kdensity dm_reswage19, bwidth(0.05) lpattern(dash_dot)), ///
       legend(label(1 "1964") label(2 "2009") label(3 "2019") region(lwidth(none)) pos(2) ring(0)) ///
       title("Spatial Distribution of Wage") graphregion(color(white)) bgcolor(white) ///
	   xtitle("Conditional Wage") ///
	   saving(conditional19, replace)
graph export conditional19.eps, replace logo(off)

***********************
*Weighted Unconditional
***********************
g dm_logwage64 = logwage1964 - meanlogwage1964
g dm_logwage09 = logwage2009 - meanlogwage2009
g dm_logwage19 = logwage2019 - meanlogwage2019
*KDE64,09
kdensity dm_logwage64 [weight = ww64], legend(region(lwidth(none))) graphregion(color(white)) bgcolor(white)  bwidth(0.03) addplot(kdensity dm_logwage09 [weight = ww09],  lpattern(--) bwidth(0.03)) title("Weighted, Unconditional") ytitle(" ") xtitle("Wage") xlabel(-.5 0 .5) xscale(r(-.6 .6)) ylabel(0 1 2 3 4 5)  note(" ") caption(" ") legend(label(1 "1964")   label(2 "2009")  position(2) ring(0)  ) saving(unconditional, replace)
graph export unconditional.eps, replace logo(off)

*KDE64,09,19
twoway (kdensity dm_logwage64 [weight = ww64], bwidth(0.05)) ///
       (kdensity dm_logwage09 [weight = ww09], bwidth(0.05) lpattern(dash)) ///
       (kdensity dm_logwage19 [weight = ww19], bwidth(0.05) lpattern(dash_dot)), ///
       legend(label(1 "1964") label(2 "2009") label(3 "2019") region(lwidth(none)) pos(2) ring(0)) ///
       title("Spatial Distribution of Wage") graphregion(color(white)) bgcolor(white) ///
	   xtitle("Unconditional Wage") ///
	   saving(unconditional19, replace)
graph export unconditional19.eps, replace logo(off)



********************************************************************************
*RENTS**************************************************************************
********************************************************************************
********************************************************************************
clear all
set more off

* Load Data
import delimited "/Users/peter/Library/CloudStorage/OneDrive-UW-Madison/Hsieh, Moretti/task/task3_Resdualize_MSA_Wage/output/pivot64_19.csv"
cd "/Users/peter/Library/CloudStorage/OneDrive-UW-Madison/Hsieh, Moretti/task/task8_Replicate_HousingCost/output"

egen mloghp64 = mean(loghp1964) 
g dm_loghp64 = loghp1964 - mloghp64

egen mloghp09 = mean(loghp2009) 
g dm_loghp09 = loghp2009 - mloghp09

egen mloghp19 = mean(loghp2019) 
g dm_loghp19 = loghp2019 - mloghp19

summ dm_loghp64 [weight = emp1964] 
summ dm_loghp09 [weight = emp2009]
summ dm_loghp19 [weight = emp2019]

g ww64 = round(emp1964)
g ww09 = round(emp2009)
g ww19 = round(emp2019)

*KDE64,09
kdensity dm_loghp64 [weight = ww64], legend(region(lwidth(none))) graphregion(color(white)) bgcolor(white) bwidth(0.03)  addplot(kdensity dm_loghp09 [weight = ww09],  lpattern(--) ) title("Spatial Distribution of Housing Costs") ytitle(" ") xtitle("Housing Costs") note(" ") caption(" ") legend(label(1 "1964") label(2 "2009")  position(2) ring(0)  ) saving(housingcost, replace)
graph export housingcost.eps, replace logo(off)

*KDE64,09,19
twoway (kdensity dm_loghp64 [weight = ww64], bwidth(0.04)) ///
       (kdensity dm_loghp09 [weight = ww09], bwidth(0.04) lpattern(dash)) ///
       (kdensity dm_loghp19 [weight = ww19], bwidth(0.04) lpattern(dash_dot)), ///
       legend(label(1 "1964") label(2 "2009") label(3 "2019") region(lwidth(none)) pos(2) ring(0)) ///
       title("Spatial Distribution of Housing Costs") graphregion(color(white)) bgcolor(white) ///
	   xtitle("Housing Costs") ///
	   saving(housingcost19, replace)
graph export housingcost19.eps, replace logo(off)


********************************************************************************
*RENTS**************************************************************************
********************************************************************************
********************************************************************************
clear all
set more off

* Load Data
import delimited "/Users/peter/Library/CloudStorage/OneDrive-UW-Madison/Hsieh, Moretti/task/task3_Resdualize_MSA_Wage/output/pivot64_19.csv"
 
cd "/Users/peter/Library/CloudStorage/OneDrive-UW-Madison/Hsieh, Moretti/task/task9_Replicate_Amenities/output"

****************************************
* Amenities  
* Follows Albouy (2012)
* Note: relative amenities are identified, but the absolute 
*       levels are not identified because we don't observe V_bar
****************************************
* Option 1: housing weighst are the same in both years 
g Q64 = (.33 * ( (hp1964 - meanhp1964)/meanhp1964 )) - (.51 * ( (wage1964 - meanwage1964)/meanwage1964 ))
g Q09 = (.33 * ( (hp2009 - meanhp2009)/meanhp2009 )) - (.51 * ( (wage2009 - meanwage2009)/meanwage2009 ))
g Q19 = (.33 * ( (hp2019 - meanhp2019)/meanhp2019 )) - (.51 * ( (wage2019 - meanwage2019)/meanwage2019 ))

* Option 2: housing weight in 1964 are lower 
*g Q64 = (.15 * ( (HP64 - pp64)/pp64 )) - (.51 * ( (wage1964 - ww64)/ww64 ))


* NOTE: Amenities are not identified in levels, but only as deviaions from mean
* This is because we don't observe utility
* Albouy's definition is a percetage deviation from average consumption
* As such, it has mean 0 by construction. 
* And of course it is negative for some cities. 
* We can't have negative amenities, as we take logs. 
* Here, I rescale it unsing a constant, equal to avearge wages in 2009
* Thus, amenties are to be interpreted as devision from a mean that is the same 
* in 1964 and 2009
g QQ64 = meanwage2009*(1+Q64) 
g QQ09 = meanwage2009*(1+Q09) 
g QQ19 = meanwage2009*(1+Q19) 

****************************************
**********************************
* AMENITIES
* PEREFECT MOBILITY
**********************************
*****************************************
g logQQ64 = log(QQ64)
egen meanlogQQ64 = mean(logQQ64)
g dmlogQQ64 = logQQ64 - meanlogQQ64

g logQQ09 = log(QQ09)
egen meanlogQQ09 = mean(logQQ09)
g dmlogQQ09 = logQQ09 - meanlogQQ09

g logQQ19 = log(QQ19)
egen meanlogQQ19 = mean(logQQ19)
g dmlogQQ19 = logQQ19 - meanlogQQ19

summ dmlogQQ64 [weight = emp1964] 
summ dmlogQQ09 [weight = emp2009]
summ dmlogQQ19 [weight = emp2019]

g ww64 = round(emp1964)
g ww09 = round(emp2009)
g ww19 = round(emp2019)

*KDE64,09
kdensity dmlogQQ64 [weight = ww64], legend(region(lwidth(none))) graphregion(color(white)) bgcolor(white) bwidth(0.045) addplot(kdensity dmlogQQ09 [weight = ww09],  lpattern(--) ) title("Spatial Distribution of Amenities") ytitle(" ") xtitle("Amenities") note(" ") caption(" ") legend(label(1 "1964") label(2 "2009")  position(2) ring(0)  ) saving(Amenities, replace)
graph export Amenities.eps, replace logo(off)

*KDE64,09,19
twoway (kdensity dmlogQQ64 [weight = ww64], bwidth(0.04)) ///
       (kdensity dmlogQQ09 [weight = ww09], bwidth(0.04) lpattern(dash)) ///
       (kdensity dmlogQQ19 [weight = ww19], bwidth(0.04) lpattern(dash_dot)), ///
       legend(label(1 "1964") label(2 "2009") label(3 "2019") region(lwidth(none)) pos(2) ring(0)) ///
       title("Spatial Distribution of Amenities") graphregion(color(white)) bgcolor(white) ///
	   xtitle("Amenities") ///
	   saving(Amenities19, replace)
graph export Amenities19.eps, replace logo(off)

