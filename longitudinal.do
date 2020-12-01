clear

//in double format
use gpscort_for_hiring, clear
gen double latitude = round(hhlatitude, 0.1)
gen double longitude = round(hhlongitude, 0.1)
label variable latitude "Latitude"
label variable longitude "Longitude"
drop hhlatitude hhlongitude
sort latitude longitude
save gpscort_for_hiring2, replace

//in double format
use rainfall_kenya_for_hiring, clear
replace latitude = round(latitude, 0.1)
replace longitude = round(longitude, 0.1)
sort latitude longitude
save rainfall_kenya_for_hiring2, replace

//merge
use gpscort_for_hiring2, clear
merge m:m latitude longitude using rainfall_kenya_for_hiring2
keep if _merge==3
drop _merge

//wokring with dates
//disp year(date) _n==1
gen dd = date
replace dd = dd-1 if day(dd) == 31
gen dekad = ceil(day(dd)/10)
tostring dekad, replace

gen years = year(dd)
gen months = month(dd)
tostring years, replace
tostring months, replace format(%02.0f)

//variable aa generated for matching obs with column name  
gen aa = "r" + years + months + dekad
save finalout, replace

use finalout, clear
//sort aa:
gsort -aa

//reoder varialbes
foreach var of varlist r20*{
	order `var', first
}
//

//generate L1-L12
forval i = 1/12{
	gen L`i' = .
}

forval i = 1/`=_N'{
	local j = 0
	quietly foreach var of varlist r20*{
		if strmatch("`var'", aa[`i']){	
				  
					local j = 0
		}
		    if `j' != 0 {
				replace L`j' = `var' in `i'
			}
			
				local j = `j' + 1
				disp `j'
				
				if `j' > 12 continue, break
	}
}


drop dekad years months dd aa
drop r20*
order date cort latitude longitude, first

regress cort L1-L12
save finalout, replace
