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
/* - for testing, other as-of dates      */
global ALTVINTAGES "2008-09-15 2015-09-15"


/* now go ahead and import the data, by default (lazy path) */

import fred GNPCA, $DATERANGE
li
qui sum GNPCA
local default=r(mean)

/* now do the same thing, but precisely defining the vintages */

clear
import fred GNPCA, $DATERANGE vintage($VINTAGE)
li
qui sum GNPCA*
local vintaged=r(mean)

di "As of `c_date', the two values are:"
di " - `default' when not specifying a vintage"
di " - `vintaged' when specifying vintage $VINTAGE"

/* Expected result :
   -------------------------------
. di "As of `c_date', the two values are:"
As of 17 Mar 2022, the two values are:

. di " - `default' when not specifying a vintage"
 - 15727.50390625 when not specifying a vintage

. di " - `vintaged' when specifying vintage $VINTAGE"
 - 15727.50390625 when specifying vintage 2021-12-31b
  -------------------------------
*/

/* now let's see why this matters - let's pull down a few more vintages */


clear
import fred GNPCA, $DATERANGE vintage($VINTAGE $ALTVINTAGES)
li GNPCA*

/* Expected result as of 2022-03-17: */
/* ------------------------------------

     +--------------------------------+
     | GN~80915   GN~50915   GNPCA_~1 |
     |--------------------------------|
  1. |  11609.8    15005.7    15727.5 |
     +--------------------------------+

NOTE: this should *never* change .
*/

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

capture confirm file "data/fred/fred_gnpca.dta"
if _rc == 0 {
    di "Re-using existing file"
    use  "data/fred/fred_gnpca.dta" , clear
}
else { 
    /* code if the file does not exist */
    /* you could do the full API pull  */
    /* conditional on the intermediate */
    /* file NOT being there.           */
    di "Reading in data from FRED API with vintage=$VINTAGE"
    clear
    import fred GNPCA, $DATERANGE vintage($VINTAGE)
    save "data/fred/fred_gnpca.dta"
    use  "data/fred/fred_gnpca.dta" , clear
} 