clear all
set more off

log using "/Users/sanghyuncho/Desktop/Stata Code/460log.smcl", replace

rename var1 sfur 
tsmktim time, start(1990m1)
tsset time
save UR, replace
rename var3 ur

save "ur.dta", replace

#SF unemployment rate
tsline sfur, title(SF unemployment rate)

#Seasonality
use sfur
gen m = month(dofm(time))
reg sfur b12.m
predict seasonality
label var seasonality "seasonality"
tsline seasonality if tin(2010m1,2010m12)

#Fitted Mean Forecast
regress sfur
predict p
tsappend, add(12)
predict f if time>tm(2020m9)
label variable f "point forecast"
predict s, stdf
gen fl=f-0.645*s
gen fu=f+0.645*s
label variable p "constant mean"
tsline sfur p f fu fl, lpattern(solid solid dash shortdash shortdash)

#AC
use sfur
ac sfur, title("San Francisco Unemployment Rate")
reg sfur time
predict e, residual
scatter e time, title("Residuals from San Francisco Unemployment Rate")
#"or use 
rvfplot, yline(0)

#heteroskedasticity check
reg sfur time
estat hettest

#Leading indicators
tsline permit corporate UIclaim
#normalize data
replace permit = (-log(permit))
replace UIclaim= (log(UIclaim))


#Granger Forecast Test (Is this a valid leading indicator?)
use sfur
reg sfur L(1/12).sfur L(1/12).permit, r
testparm L(1/12).permit 
reg sfur L(1/12).sfur L(1/12).corporate, r
testparm L(1/12).corporate
reg sfur L(1/12).sfur L(1/12).UIclaim, r
testparm L(1/12).UIclaim
"Only use one that rejects (<0.05) the test as a leading indicator

#AR Model
use sfur
reg sfur, r
estimates store ar0
reg sfur L.sfur, r
estimates store ar1
reg sfur L(1/2).sfur, r 
estimates store ar2
reg sfur L(1/3).sfur, r
estimates store ar3
reg sfur L(1/4).sfur, r
estimates store ar4
reg sfur L(1/5).sfur, r 
estimates store ar5
reg sfur L(1/6).sfur, r 
estimates store ar6
reg sfur L(1/7).sfur, r 
estimates store ar7
reg sfur L(1/8).sfur, r 
estimates store ar8
reg sfur L(1/9).sfur, r 
estimates store ar9
reg sfur L(1/10).sfur, r 
estimates store ar10
reg sfur L(1/11).sfur, r 
estimates store ar11
reg sfur L(1/12).sfur, r 
estimates store ar12
estimates stats ar0 ar1 ar2 ar3 ar4 ar5 ar6 ar7 ar8 ar9 ar10 ar11 ar12
#Pick AR5 (AIC:  674.8214) 

#Building Permit
reg sfur L(1/7).sfur L.permit, r
estimates store permit1
reg sfur L(1/7).sfur L(1/2).permit, r
estimates store permit2
reg sfur L(1/7).sfur L(1/4).permit, r
estimates store permit3
reg sfur L(1/7).sfur L(1/6).permit, r
estimates store permit4
reg sfur L(1/7).sfur L(1/8).permit, r
estimates store permit5
reg sfur L(1/7).sfur L(1/10).permit, r
estimates store permit6
reg sfur L(1/7).sfur L(1/12).permit, r
estimates store permit7
estimates stats ar7 permit1 permit2 permit3 permit4 permit5 permit6 permit7

#BAA-AAA
reg sfur L(1/7).sfur L.corporate, r
estimates store co1
reg sfur L(1/7).sfur L(1/2).corporate, r
estimates store co2
reg sfur L(1/7).sfur L(1/4).corporate, r
estimates store co3
reg sfur L(1/7).sfur L(1/6).corporate, r
estimates store co4
reg sfur L(1/7).sfur L(1/8).corporate, r
estimates store co5
reg sfur L(1/7).sfur L(1/10).corporate, r
estimates store co6
reg sfur L(1/7).sfur L(1/12).corporate, r
estimates store co7
estimates stats ar7 permit1 co1 co2 co3 co4 co5 co6 co7

#UI Claims
reg sfur L(1/7).sfur L.UIclaim, r
estimates store claim1
reg sfur L(1/7).sfur L(1/2).UIclaim, r
estimates store claim2
reg sfur L(1/7).sfur L(1/4).UIclaim, r
estimates store claim3
reg sfur L(1/7).sfur L(1/6).UIclaim, r
estimates store claim4
reg sfur L(1/7).sfur L(1/8).UIclaim, r
estimates store claim5
reg sfur L(1/7).sfur L(1/10).UIclaim, r
estimates store claim6
reg sfur L(1/7).sfur L(1/12).UIclaim, r
estimates store claim7
estimates stats ar7 permit1 co4 claim1 claim2 claim3 claim4 claim5 claim6 claim7

#combine omitting claim
reg sfur L(1/7).sfur L(1/6).corporate L.permit, r
estimates store combi0
reg sfur L(1/7).sfur L(1/6).corporate L(1/2).permit, r
estimates store combi1
reg sfur L(1/7).sfur L(1/6).corporate L(1/4).permit, r
estimates store combi2
reg sfur L(1/7).sfur L(1/6).corporate L(1/6).permit, r
estimates store combi3
reg sfur L(1/7).sfur L(1/6).corporate L(1/8).permit, r
estimates store combi4
reg sfur L(1/7).sfur L(1/6).corporate L(1/10).permit, r
estimates store combi5
reg sfur L(1/7).sfur L(1/6).corporate L(1/12).permit, r
estimates store combi6
estimates stats ar7 co4 combi0 combi1 combi2 combi3 combi4 combi5 combi6



#Combine
reg sfur L(1/7).sfur L(1/12).UIclaim L.permit L.corporate, r
estimates store comb0
reg sfur L(1/7).sfur L(1/12).UIclaim L(1/2).permit L(1/2).corporate, r
estimates store comb1
reg sfur L(1/7).sfur L(1/12).UIclaim L(1/4).permit L(1/4).corporate, r
estimates store comb2
reg sfur L(1/7).sfur L(1/12).UIclaim L(1/6).permit L(1/6).corporate, r
estimates store comb3
reg sfur L(1/7).sfur L(1/12).UIclaim L(1/8).permit L(1/8).corporate, r
estimates store comb4

estimates stats ar7 claim7 comb0 comb1 comb2 comb3 comb4

#"12step ahead forecast

tsappend, add(12)
reg sfur L(1/7).sfur L(1/12).UIclaim L(1/6).permit L(1/6).corporate
predict y1
predict s, stdf
gen y1l = y1-1.645*s
gen y1u = y1+1.645*s

reg sfur L(2/8).sfur L(2/13).UIclaim L(2/7).permit L(2/7).corporate
predict y2
predict s2, stdf
gen y2l = y2-1.645*s2
gen y2u = y2+1.645*s2

reg sfur L(3/9).sfur L(3/14).UIclaim L(3/8).permit L(3/8).corporate
predict y3
predict s3, stdf
gen y3l = y3-1.645*s3
gen y3u = y3+1.645*s3

reg sfur L(4/10).sfur L(4/15).UIclaim L(4/9).permit L(4/9).corporate
predict y4
predict s4, stdf
gen y4l = y4-1.645*s4
gen y4u = y4+1.645*s4

reg sfur L(5/11).sfur L(5/16).UIclaim L(5/10).permit L(5/10).corporate
predict y5
predict s5, stdf
gen y5l = y5-1.645*s5
gen y5u = y5+1.645*s5

reg sfur L(6/12).sfur L(6/17).UIclaim L(6/11).permit L(6/11).corporate
predict y6
predict s6, stdf
gen y6l = y6-1.645*s6
gen y6u = y6+1.645*s6

reg sfur L(7/13).sfur L(7/18).UIclaim L(7/12).permit L(7/12).corporate
predict y7
predict s7, stdf
gen y7l = y7-1.645*s7
gen y7u = y7+1.645*s7

reg sfur L(8/14).sfur L(8/19).UIclaim L(8/13).permit L(8/13).corporate
predict y8
predict s8, stdf
gen y8l = y8-1.645*s8
gen y8u = y8+1.645*s8

reg sfur L(9/15).sfur L(9/20).UIclaim L(9/14).permit L(9/14).corporate
predict y9
predict s9, stdf
gen y9l = y9-1.645*s9
gen y9u = y9+1.645*s9

reg sfur L(10/16).sfur L(10/21).UIclaim L(10/15).permit L(10/15).corporate
predict y10
predict s10, stdf
gen y10l = y10-1.645*s10
gen y10u = y10+1.645*s10

reg sfur L(11/17).sfur L(11/22).UIclaim L(11/16).permit L(11/16).corporate
predict y11
predict s11, stdf
gen y11l = y11-1.645*s11
gen y11u = y11+1.645*s11

reg sfur L(12/18).sfur L(12/23).UIclaim L(12/17).permit L(12/17).corporate
predict y12
predict s12, stdf
gen y12l = y12-1.645*s12
gen y12u = y12+1.645*s12

egen p=rowfirst(y1 y2 y3 y4 y5 y6 y7 y8 y9 y10 y11 y12) if time>=tm(2020m10)
egen pu=rowfirst(y1u y2u y3u y4u y5u y6u y7u y8u y9u y10u y11u y12u) if time>=tm(2020m10)
egen pl=rowfirst(y1l y2l y3l y4l y5l y6l y7l y8l y9l y10l y11l y12l) if time>=tm(2020m10)
label var p "forecast"
label var pl "lower forecast interval"
label var pu "upper forecast interval"
tsline sfur p pu pl if time>tm(2018m9), title("Forecast of SF Unemployment Rate Using Combined Model") lpattern(solid dash shortdash shortdash)
graph rename Forecast
----------------------

"Although this forecast seems okay, 




#"12step ahead forecast omitting claims

tsappend, add(12)
reg sfur L(1/7).sfur L.permit L(1/6).corporate
predict y1
predict s, stdf
gen y1l = y1-1.645*s
gen y1u = y1+1.645*s

reg sfur L(2/8).sfur  L(2/2).permit L(2/7).corporate
predict y2
predict s2, stdf
gen y2l = y2-1.645*s2
gen y2u = y2+1.645*s2

reg sfur L(3/9).sfur  L(3/3).permit L(3/8).corporate
predict y3
predict s3, stdf
gen y3l = y3-1.645*s3
gen y3u = y3+1.645*s3

reg sfur L(4/10).sfur  L(4/4).permit L(4/9).corporate
predict y4
predict s4, stdf
gen y4l = y4-1.645*s4
gen y4u = y4+1.645*s4

reg sfur L(5/11).sfur  L(5/5).permit L(5/10).corporate
predict y5
predict s5, stdf
gen y5l = y5-1.645*s5
gen y5u = y5+1.645*s5

reg sfur L(6/12).sfur L(6/6).permit L(6/11).corporate
predict y6
predict s6, stdf
gen y6l = y6-1.645*s6
gen y6u = y6+1.645*s6

reg sfur L(7/13).sfur  L(7/7).permit L(7/12).corporate
predict y7
predict s7, stdf
gen y7l = y7-1.645*s7
gen y7u = y7+1.645*s7

reg sfur L(8/14).sfur  L(8/8).permit L(8/13).corporate
predict y8
predict s8, stdf
gen y8l = y8-1.645*s8
gen y8u = y8+1.645*s8

reg sfur L(9/15).sfur  L(9/9).permit L(9/14).corporate
predict y9
predict s9, stdf
gen y9l = y9-1.645*s9
gen y9u = y9+1.645*s9

reg sfur L(10/16).sfur  L(10/10).permit L(10/15).corporate
predict y10
predict s10, stdf
gen y10l = y10-1.645*s10
gen y10u = y10+1.645*s10

reg sfur L(11/17).sfur  L(11/11).permit L(11/16).corporate
predict y11
predict s11, stdf
gen y11l = y11-1.645*s11
gen y11u = y11+1.645*s11

reg sfur L(12/18).sfur  L(12/12).permit L(12/17).corporate
predict y12
predict s12, stdf
gen y12l = y12-1.645*s12
gen y12u = y12+1.645*s12

egen p=rowfirst(y1 y2 y3 y4 y5 y6 y7 y8 y9 y10 y11 y12) if time>=tm(2020m10)
egen pu=rowfirst(y1u y2u y3u y4u y5u y6u y7u y8u y9u y10u y11u y12u) if time>=tm(2020m10)
egen pl=rowfirst(y1l y2l y3l y4l y5l y6l y7l y8l y9l y10l y11l y12l) if time>=tm(2020m10)
label var p "forecast"
label var pl "lower forecast interval"
label var pu "upper forecast interval"
tsline sfur p pu pl if time>tm(2018m9), title("UR Forecast, Combined Model 2") lpattern(solid dash shortdash shortdash)
graph rename Forecast2
----------------------


