*Splitting Data into 4 parts*
use "/Users/sanghyuncho/Desktop/reduced_chicagotrip.dta"
drop if area<=30
save trip31to77
clear 
use "/Users/sanghyuncho/Desktop/reduced_chicagotrip.dta"
drop if area>30
save trip1to30
clear 
use "/Users/sanghyuncho/Desktop/trip1to30.dta"
drop if area<=15
save trip16to30
clear 
use "/Users/sanghyuncho/Desktop/trip1to30.dta"
drop if area>15
save trip1to15
clear 
use "/Users/sanghyuncho/Desktop/trip31to77.dta"
drop if area<=54
save trip55to77
clear 
use "/Users/sanghyuncho/Desktop/trip31to77.dta"
drop if area>54
save trip31to54
clear 


*Reformatting the file, counting the number of trips by hour, month or year within each area*
use "/Users/sanghyuncho/Desktop/trip1to15.dta"
egen trip_count = count(id), by(month area)
bysort area month (trip_count): keep if _n == _N
drop date hour day year id
save m115
clear
use "/Users/sanghyuncho/Desktop/trip16to30.dta"
egen trip_count = count(id), by(month area)
bysort area month (trip_count): keep if _n == _N
drop date hour day year id
save m1630
clear
use "/Users/sanghyuncho/Desktop/trip31to54.dta"
egen trip_count = count(id), by(month area)
bysort area month (trip_count): keep if _n == _N
drop date hour day year id
save m3154
clear
use "/Users/sanghyuncho/Desktop/trip55to77.dta"
egen trip_count = count(id), by(month area)
bysort area month (trip_count): keep if _n == _N
drop date hour day year id
save m5577
clear


use "/Users/sanghyuncho/Desktop/trip1to15.dta"
egen trip_count = count(id), by(year area)
bysort area year (trip_count): keep if _n == _N
drop date hour day month id
save y115
clear
use "/Users/sanghyuncho/Desktop/trip16to30.dta"
egen trip_count = count(id), by(year area)
bysort area year (trip_count): keep if _n == _N
drop date hour day month id
save y1630
clear
use "/Users/sanghyuncho/Desktop/trip31to54.dta"
egen trip_count = count(id), by(year area)
bysort area year (trip_count): keep if _n == _N
drop date hour day month id
save y3154
clear
use "/Users/sanghyuncho/Desktop/trip55to77.dta"
egen trip_count = count(id), by(year area)
bysort area year (trip_count): keep if _n == _N
drop date hour day month id
save y5577
clear


*Appending 4 splits back into one chunk.
*Start by opening hourly_trip1to15 (base dataset)
use "/Users/sanghyuncho/Desktop/trip1to15.dta"
append using monthly_trip16to30
append using monthly_trip31to54
append using monthly_trip55to77

rename (hour trip_month) (trip_hour month)
save monthly_trip_total

**Reformatting the file, counting the number of trips by hour, month or year within each area**
use "/Users/sanghyuncho/Desktop/Chicago Data/Reduced Full Data/reduced_chicagocrime.dta"
egen crime_count = count(id), by(crimetype crime_month area)
bysort area crime_month crimetype (crime_count) : keep if _n == _N
bysort area crime_month (crimetype): keep if crimetype==1
drop numeric_iucr
rename (crime_count id primarytype iucr date block locationdescription crime_year crime_day crime_month description crimetype hour) (c1_count c1_id c1_primarytype c1_iucr c1_date c1_block c1_locationdescription c1_year c1_day month c1_description c1_crimetype c1_hour)
order area month c1_count
save monthly_c1, replace
clear
use "/Users/sanghyuncho/Desktop/Chicago Data/Reduced Full Data/reduced_chicagocrime.dta"
egen crime_count = count(id), by(crimetype crime_month area)
bysort area crime_month crimetype (crime_count) : keep if _n == _N
bysort area crime_month (crimetype): keep if crimetype==0
drop numeric_iucr
rename (crime_count id primarytype iucr date block locationdescription crime_year crime_day crime_month description crimetype hour) (c0_count c0_id c0_primarytype c0_iucr c0_date c0_block c0_locationdescription c0_year c0_day month c0_description c0_crimetype c0_hour) 
order area month c0_count
save monthly_c0, replace
clear
use "/Users/sanghyuncho/Desktop/Chicago Data/Reduced Full Data/monthly_c0.dta"
merge m:1 area month using monthly_c1.dta
replace c1_count = 0 if c1_count == .
drop _merge
sort area month
save monthly_crime, replace
clear

use "/Users/sanghyuncho/Desktop/monthly_trip_total.dta"
sort area month
merge m:1 area hour using monthly_crime.dta
replace c1_count = 0 if c1_count == .
replace c0_count = 0 if c0_count == .
drop _merge
save monthly_total, replace


********************************************************************************
********************************************************************************
********************************************************************************
**SETTING UP CRIME DATA**
gen crime_datetime = clock(date, "MDY hms")
gen crime_date = date(date, "MDY#")
gen crime_day = dow(crime_date)
gen crime_hour = hh(crime_datetime)
gen crime_month = month(crime_date)

*Give number ID to each observations and make it string
gen id = _n
tostring id, replace
*Make a variable that allocates 1 to any values in iucr that matches with given integer (sexual Assault cases) and 0 otherwise.
egen crimetype = anymatch(numeric_iucr), values(261 262 263 264 265 266 271 272 273 274 275 281 291 1544 1562 1563 1564 1565 1566 1570 1572 1574 1576 1578 1580 1585 1590 5004 )
*sort the data in the order of area and hours 
order id area hour crimetype primarytype
sort area crime_hour crimetype
*Count under given criteria
egen crime_count = count(id), by(crimetype crime_year area)
*Only keep one number when redundant count_id_by_t_i
bysort area crime_year crimetype (crime_count) : keep if _n == _N
bysort area crime_year (crimetype): keep if crimetype==1
*Data divides into two c_0 and c_1, bysort & save in different name for each c. 
bysort area crime_year (crimetype): keep if crimetype==0
*Counted the number that happend in area i at hour h by crime type 0 & 1.
*(Type=1 for sexual violence and 0 otherwise: Variable C1=Type1  C0=Type0 Crime) 

**TRIP DATA**
gen trip_datetime = clock(tripstarttimestamp, "MDY hms")
gen trip_date = date(tripstarttimestamp, "MDY#")
gen trip_day = dow(trip_date)
gen trip_hour = hh(trip_datetime)
gen trip_month = month(trip_date)
gen trip_year = year(trip_date)
*Count under given criteria
egen trip_count = count(id), by(hour area)
*sort the data in the order of area and hours 
order trip_id area trip_hour trip_count
sort trip_id area trip_hour
*Only keep one number from redundant count_trips_by_t_i
bysort area hour (trip_count): keep if _n == _N

*TAXI DATA**
gen taxi19_datetime = clock(tripstarttimestamp, "MDY hms")
gen taxi19_date = date(tripstarttimestamp, "MDY#")
gen taxi19_day = dow(trip_date)
gen hour = hh(trip_datetime)
gen taxi19_month = month(trip_date)
gen id = _n
tostring id, replace

egen taxi_count = count(id), by(hour area)

bysort area hour (taxi_count): keep if _n == _N

drop day month id year

egen taxi_count = count(id), by(hour area)
bysort area hour (taxi_count): keep if _n == _N
drop day month id year
save hourlytaxi.dta

use taxi.dta
egen taxi_count = count(id), by(day area)
bysort area day (taxi_count): keep if _n == _N
drop hour month id year
save dailytaxi.dta

use taxi.dta
egen taxi_count = count(id), by(month area)
bysort area month (taxi_count): keep if _n == _N
drop hour day id year
save monthlytaxi.dta

use taxi.dta
egen taxi_count = count(id), by(year area)
bysort area year (taxi_count): keep if _n == _N
drop hour day id month
save yearlytaxi.dta

use reduced_chicagocrime
egen c1_count = count(id), by(crimetype day area)
bysort area day crimetype (c1_count) : keep if _n == _N
bysort area day (crimetype): keep if crimetype==1
drop year hour month id crimetype
save dailyc1

use reduced_chicagocrime
egen c0_count = count(id), by(crimetype day area)
bysort area day crimetype (c0_count) : keep if _n == _N
bysort area day (crimetype): keep if crimetype==0
drop year hour month id crimetype
save dailyc0

use reduced_chicagocrime
egen c1_count = count(id), by(crimetype hour area)
bysort area hour crimetype (c1_count) : keep if _n == _N
bysort area hour (crimetype): keep if crimetype==1
drop year day month id crimetype
save hourlyc1

use reduced_chicagocrime
egen c0_count = count(id), by(crimetype hour area)
bysort area hour crimetype (c0_count) : keep if _n == _N
bysort area hour (crimetype): keep if crimetype==0
drop year day month id crimetype
save hourlyc0

use reduced_chicagocrime
egen c1_count = count(id), by(crimetype month area)
bysort area month crimetype (c1_count) : keep if _n == _N
bysort area month (crimetype): keep if crimetype==1
drop year day hour id crimetype
save monthlyc1

use reduced_chicagocrime
egen c0_count = count(id), by(crimetype month area)
bysort area month crimetype (c0_count) : keep if _n == _N
bysort area month (crimetype): keep if crimetype==0
drop year day hour id crimetype
save monthlyc0

use reduced_chicagocrime
egen c1_count = count(id), by(crimetype year area)
bysort area year crimetype (c1_count) : keep if _n == _N
bysort area year (crimetype): keep if crimetype==1
drop month day hour id crimetype
save yearlyc1

use reduced_chicagocrime
egen c0_count = count(id), by(crimetype year area)
bysort area year crimetype (c0_count) : keep if _n == _N
bysort area year (crimetype): keep if crimetype==0
drop month day hour id crimetype
save yearlyc0

*Repeat this for taxi20 data and generate  daily_taxi20.dta
append using hourly_taxi20
save hourly_taxi.dta

*------------MERGING C_1 AND C_0 WITH TRIP DATA------------*
**PREPARING TRIP DATA FOR THE MERGE**
rename (trip_hour pickupcommunityarea count_trips_by_t_i) (hour area trip_count)
order area hour trip_count 
drop trip_date trip_datetime
rename (id tripstarttimestamp) (trip_id trip_date)

**PREPARING C_0 DATA FOR THE MERGE**
drop numeric_iucr
rename (crime_count id primarytype iucr date block locationdescription crime_year crime_day crime_month description crimetype) (c0_count c0_id c0_primarytype c0_iucr c0_date c0_block c0_locationdescription c0_year c0_day c0_month c0_description c0_crimetype) 
order area hour c0_count

**PREPARING C_1 DATA FOR THE MERGE**
drop numeric_iucr
rename (crime_count id primarytype iucr date block locationdescription crime_year crime_day crime_month description crimetype) (c1_count c1_id c1_primarytype c1_iucr c1_date c1_block c1_locationdescription c1_year c1_day c1_month c1_description c1_crimetype)
order area hour c1_count

**MERGING**
use hourlytrip
merge m:1 area hour using hourlyc1.dta
replace c1_count = 0 if c1_count == .
drop _merge
merge m:1 area hour using hourlyc0.dta
replace c0_count = 0 if c0_count == .
drop _merge
merge m:1 area hour using hourlytaxi.dta
replace taxi_count = 0 if taxi_count == .
drop _merge
drop if area == .
save hourlytotal

use dailytrip
merge m:1 area day using dailyc1.dta
replace c1_count = 0 if c1_count == .
drop _merge
merge m:1 area day using dailyc0.dta
replace c0_count = 0 if c0_count == .
drop _merge
merge m:1 area day using dailytaxi.dta
replace taxi_count = 0 if taxi_count == .
drop _merge
drop if area == .
save dailytotal

use monthlytrip
merge m:1 area month using monthlyc1.dta
replace c1_count = 0 if c1_count == .
drop _merge
merge m:1 area month using monthlyc0.dta
replace c0_count = 0 if c0_count == .
drop _merge
merge m:1 area month using monthlytaxi.dta
replace taxi_count = 0 if taxi_count == .
drop _merge
drop if area == .
save monthlytotal

use yearlytrip
merge m:1 area year using yearlyc1.dta
replace c1_count = 0 if c1_count == .
drop _merge
merge m:1 area year using yearlyc0.dta
replace c0_count = 0 if c0_count == .
drop _merge
merge m:1 area year using yearlytaxi.dta
replace taxi_count = 0 if taxi_count == .
drop _merge
drop if area == .
save yearlytotal
**Repeat the same process to categorize data by month and year**


**RUNNING MODELS**
order area hour trip_count c0_count c1_count
gen c1_dummy=1
replace c1_dummy=0 if c1_count==0
gen c1_dummy=1
replace c1_dummy=0 if c1_count==0
gen log_trip = log(trip_count)
gen c1_rate=c1_count*(100000/2714500)
gen c0_rate=c0_count*(100000/2714500)

order area hour trip_count log_trip c0_count c0_rate c0_dummy c1_count c1_rate c1_dummy


**GRAPHING**
egen sumtrip= sum(trip_count)
gen percenttrip= (trip_count/sumtrip) *100


. label variable c0_count "Non-sexual Crime Count"
. label variable c1_count "Sexual Crime Count"
. label variable taxi19_count "Feb1-August31 2019 taxi trips"
. label variable taxi20_count "Feb1-August31 2020 taxi trips"
. label variable trip_count "Oct2,2018-Dec31,2020 TNC trips"
. label variable hour "0-23 0=12am"
. label variable day "0-6 0=Sunday"
. label variable log_trip "log(trip_count+1)"
. label variable c0_rate "Crime rate of non-sexual crimes (crime/2.7m)*0.1m"
. label variable c0_dummy "1 if c0_count is not 0, otherwise 0"
. label variable c1_rate "Crime rate of sexual crimes (crime/2.7m)*0.1m"
. label variable c1_dummy "1 if c1_count is not 0, otherwise 0"


drop date id
save, replace
use monthlyc1
drop date id
save, replace
use monthlyc0
drop date id
save, replace
use yearlyc1
drop date id
save, replace
use hourlyc1
drop date id
save, replace
use hourlyc0
drop date id
save, replace

use trip1to15
order area year month day hour date id
gen trip_date = date(date, "MDY#")
sort area trip_date hour
order area year month trip_date hour date id day
egen trip_count = count(id), by (trip_date hour area)
bysort trip_date hour area (trip_count): keep if _n == _N
drop date id
rename trip_date date
save t0115

use trip31to54
order area year month day hour date id
gen trip_date = date(date, "MDY#")
sort area trip_date hour
order area year month trip_date hour date id day
egen trip_count = count(id), by (trip_date hour area)
bysort trip_date hour area (trip_count): keep if _n == _N
drop date id
rename trip_date date
save t3154, replace

use trip55to77
order area year month day hour date id
gen trip_date = date(date, "MDY#")
sort area trip_date hour
order area year month trip_date hour date id day
egen trip_count = count(id), by (trip_date hour area)
bysort trip_date hour area (trip_count): keep if _n == _N
drop date id
rename trip_date date
save t5577, replace


use trip31to54
order area year month day hour date id
gen trip_date = date(date, "MDY#")
sort area taxi_date hour
order area year month taxi_date hour date id day
egen taxi_count = count(id), by (taxi_date hour area)
bysort taxi_date hour area (taxi_count): keep if _n == _N
drop date id
rename taxi_date date
save taxi2


egen crime_count = count(id), by(crimetype crime_year area)
bysort area crime_year crimetype (crime_count) : keep if _n == _N
bysort area crime_year (crimetype): keep if crimetype==1
bysort area crime_year (crimetype): keep if crimetype==0


gen crime_date = clock(date, "MDY#")
rename (crime_year crime_month crime_day crimetype) (year month day type)
sort area crime_date hour
order area year month crime_date hour date id day 
egen c1_count = count(id), by(type crime_date hour area)
bysort area crime_date hour type (c1_count) : keep if _n == _N
bysort area crime_date hour (type): keep if type==0

bysort area crime_date hour (type): keep if type==1

egen c0_count = count(id), by(crimetype day area)
bysort area day crimetype (c0_count) : keep if _n == _N
bysort area day (crimetype): keep if crimetype==0
drop year hour month id crimetype

sort area year month date day hour trip_count
order area year month date day hour trip_count


