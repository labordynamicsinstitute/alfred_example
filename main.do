/* First, download as usually */

include "set_key.do"
include "config.do"

set fredkey $FREDKEY

/* set some parameters we want to re-use */
/* - the daterange we want               */
global DATERANGE "daterange(2007-01-01 2007-01-01)"
/* - the as-of date we want              */
local c_date = c(current_date)
global VINTAGE "2021-12-31"
global gdptag "NQGSP"




/* LESSON: 
   - always use a fixed date to query the API.
   - some series change as time progresses, even for historical values.
*/

/* SUPPLEMENTARY LESSON */
/* Save the data pulled through the API as an intermediate dataset */
/* and if permissible by the license (check!), redistribute it     */
/* in case that the API is deprecated and won't work in the future */

cap mkdir data
cap mkdir data/fred
global gdpdata "data/fred/fred_qgdp.dta"

/* generate the state names */
/* requires "statastates" */
/* run once to generate the dataset */

statastates

/* now read in the dataset */
use "`c(sysdir_personal)'statastates_data/statastates.dta"
local N=_N 
global gdpseries 
forvalues row=1 (1) `N'{
   local state = state_abbrev[`row']
   global gdpseries $gdpseries `state'$gdptag
}

capture confirm file "$gdpdata"
if _rc == 0 {
    di "Re-using existing file"
    use  "$gdpdata" , clear
}
else { 
    /* code if the file does not exist */
    /* you could do the full API pull  */
    /* conditional on the intermediate */
    /* file NOT being there.           */
    di "Reading in data from FRED API with vintage=$VINTAGE"
    clear
    import fred $gdpseries, $DATERANGE vintage($VINTAGE)
    save "$gdpdata"
    use  "$gdpdata" , clear
} 