capture program drop gensumstat
program define gensumstat
	version 15.0
	
	/* Take a list of variables and create mean, standard deviation, median, 
	 * lower quartile, and upper quartile variables adjacent to them.
	 *
	 * By option - Produce summary statistics variables for each of a given variable
	 *             CATEGORIES MUST BE NUMBERED 1 TO N
	 */
	syntax varlist, [BY(string)]
	
	quietly {
	
		foreach var of local varlist {
			
			if "`by'" != "" {
				
				//Check if 'by' variable is a string
				if substr("`:type `by''" , 1, 3) == "str" {
				
					display as error "Can't use a string as a 'by' variable."
					error
				}
				else {
					
					label list `by'
					local count = r(k)  //No. of categories
					
					if r(max) != r(k) {
					
						display as error "This scenario is too complex for me to code at the moment."
						error
					}
					else {
					
						forvalues i = 1(1)`count' {
						
							sum `var' if `by' == `i', detail
							
							if `i' == 1 {
								
								gen `var'_N      = r(N)    if `by' == `i'
								gen `var'_mean   = r(mean) if `by' == `i'
								gen `var'_sd     = r(sd)   if `by' == `i'
								gen `var'_p50    = r(p50)  if `by' == `i'
								gen `var'_lq     = r(p25)  if `by' == `i'
								gen `var'_uq     = r(p75)  if `by' == `i'
								
								order `var'_N `var'_mean `var'_sd `var'_p50 `var'_lq `var'_uq, after(`var')
							}
							else {
								
								replace `var'_N      = r(N)    if `by' == `i'
								replace `var'_mean   = r(mean) if `by' == `i'
								replace `var'_sd     = r(sd)   if `by' == `i'
								replace `var'_p50    = r(p50)  if `by' == `i'
								replace `var'_lq     = r(p25)  if `by' == `i'
								replace `var'_uq     = r(p75)  if `by' == `i'
							}
						}
					}
				}
			}
			else {
			
				//Check if variable is a string
				if substr("`:type `var''" , 1, 3) == "str" {
					
					noisily display as text "`var' is a string. Can't compute summary statistics for `var'."
				}
				else {
					
					sum `var', detail
			
					gen `var'_N      = r(N)
					gen `var'_mean   = r(mean)
					gen `var'_sd     = r(sd)
					gen `var'_p50    = r(p50)
					gen `var'_lq     = r(p25)
					gen `var'_uq     = r(p75)
					
					order `var'_N `var'_mean `var'_sd `var'_p50 `var'_lq `var'_uq, after(`var')
				}
			}
		}
	}
end
