clear all
set more off
cap ssc install regsave

cap log using "./code/regress_CPS.log", replace

cd "/Users/peter/Library/CloudStorage/OneDrive-UW-Madison/Hsieh, Moretti/task/task2_Regress_CPS"

* 1964
{
qui{
	infile using "./input/MIRROR_data/CPS/cps64/cpsmw.dct", using("/input/MIRROR_data/CPS/cps64/cpsmw64.raw")
	// infile using "C:/Users/hyoon76/OneDrive - UW-Madison/5.Miscellaneous/Hsieh-Moretti(2019)/data/CPS/cps64/cpsmw.dct", using("C:/Users/hyoon76/OneDrive - UW-Madison/5.Miscellaneous/Hsieh-Moretti(2019)/data/CPS/cps64/cpsmw64.raw")
	}

g lnwage = ln(perswag)
g female = sex == 2
g nonwhite = race!=1
g highmore = highgra>=11
g colmore = highgra>=14

label var lnwage "log(Wage)"
label var highmore "High School or More"
label var colmore "College or More"
label var female "Female"
label var nonwhite "Non-White"
label var age "Age"

keep lnwage highmore colmore female nonwhite age
g year = 1964

save "./output/data_cps1964.dta", replace

reg lnwage highmore colmore female nonwhite age, vce(robust)

regsave using "./output/coef.dta", addlabel(year, 1964) replace
}


* 2009
clear all	
{
foreach month in "jan" "feb" "mar" "apr" "may" "jun" "jul" "aug" "sep" "oct" "nov" "dec"{
	di "`month'"
	clear all
	preserve
	{
		qui{
			infile using "./input/MIRROR_data/CPS/cps09/cpsdec09.dct", using("./input/MIRROR_data/CPS/cps09/`month'09pub.raw")
			// infile using "C:/Users/hyoon76/OneDrive - UW-Madison/5.Miscellaneous/Hsieh-Moretti(2019)/data/CPS/cps09/cpsdec09.dct", using("C:/Users/hyoon76/OneDrive - UW-Madison/5.Miscellaneous/Hsieh-Moretti(2019)/data/CPS/cps09/`month'09pub.raw")
			tempfile temp
			save `temp', replace
			}
	}
	restore
	append using `temp'
}

g lnwage = ln(prernwa)
g female = pesex == 2
g nonwhite = ptdtrace >= 2
g highmore = peeduca >= 36
g colmore = peeduca >= 40
ren peage age

label var lnwage "log(Wage)"
label var highmore "High School or More"
label var colmore "College or More"
label var female "Female"
label var nonwhite "Non-White"
label var age "Age"

keep lnwage highmore colmore female nonwhite age
g year = 2009

save "./output/data_cps2009.dta", replace

reg lnwage highmore colmore female nonwhite age, vce(robust)

regsave using "./output/coef.dta", addlabel(year, 2009) append
}

log close

*2019
clear all
set more off
cap ssc install regsave

cd "/Users/peter/Library/CloudStorage/OneDrive-UW-Madison/Hsieh, Moretti/data/CPS/cps19"


use cpsb201901, clear


foreach month in 02 03 04 05 06 07 08 09 10 11 12 {
    append using cpsb2019`month'
}
save "/Users/peter/Library/CloudStorage/OneDrive-UW-Madison/Hsieh, Moretti/task/task2_Regress_CPS/output/data_cps2019.dta"

g lnwage = ln(prernwa)
g female = pesex == 2
g nonwhite = ptdtrace >= 2
g highmore = peeduca >= 36
g colmore = peeduca >= 40
ren prtage age

label var lnwage "log(Wage)"
label var highmore "High School or More"
label var colmore "College or More"
label var female "Female"
label var nonwhite "Non-White"
label var age "Age"

keep lnwage highmore colmore female nonwhite age
g year = 2019

save, replace

reg lnwage highmore colmore female nonwhite age, vce(robust)

regsave using "../../../task/task2_Regress_CPS/output/coef.dta", addlabel(year, 2019) append


log close
