
*=================
* PROBLEM 1
*=================

*---log-file---*
log using "C:\PUCP\Econometría Avanzada Aplicada\Problem set\problem_1.log", replace

/*-------------*/
/* Import data */
/*-------------*/
cd "C:\PUCP\Econometría Avanzada Aplicada\Problem set"
global year "98 99 00 01 02 03 04 05 06"
foreach yy of global year {

if `yy'==98 | `yy'==99 {
shell curl -o cbp`yy'st.zip "https://www2.census.gov/programs-surveys/cbp/datasets/19`yy'/cbp`yy'st.zip"
}
else if `yy'!=98 | `yy'!=99 {
shell curl -o cbp`yy'st.zip "https://www2.census.gov/programs-surveys/cbp/datasets/20`yy'/cbp`yy'st.zip"
}
unzipfile cbp`yy'st.zip, replace
import delimited "cbp`yy'st.txt", clear
keep if substr(naics,4,3)=="///"

keep fipstate naics emp qp1 ap est
if `yy'==98 | `yy'==99 {
	gen year=19`yy' 
}
else if `yy'!=98 | `yy'!=99 {
	gen year=20`yy' 
}
save cbp`yy'st.dta, replace
}

use cbp98st.dta, clear 
append using cbp99st.dta 
append using cbp00st.dta 
append using cbp01st.dta 
append using cbp02st.dta 
append using cbp03st.dta
append using cbp04st.dta 
append using cbp05st.dta
append using cbp06st.dta 

**---1---**
*The level of observation is the industry category*

**---2---**
*dummy variable post_china*
gen post_china = 0
replace post_china = 1 if year >=2001 

**---3---**
*dummy variable manuf*
gen manuf = 0
replace manuf = 1 if substr(naics,1,1)=="3"

**---4---**
*Treatment group: manufacturing industries(manuf=1)*
*Control group: non-manufacturing industries(manuf=0)*
*Intervention time: year 2001*

gen emp1=emp if year < 2001
gen emp2=emp if year >= 2001

tabulate manuf 
  describe emp* 
 
 // Employment in manuf pre 
 egen empM1=mean(emp1) if manuf==1 
 // Employment in manuf post
 egen empM2=mean(emp2) if manuf==1 
 // Employment in non manuf pre
 egen empNM1=mean(emp1) if manuf==0  
 // Employment in non manuf post 
 egen empNM2=mean(emp2) if manuf==0  
 // Emp manuf post - Emp manuf pre
 gen dfempM= empM2-empM1
 // Emp non manuf post - Emp non manuf pre
 gen dfempNM= empNM2-empNM1
 
 egen dfemp_M=max(dfempM)
 egen dfemp_NM=max(dfempNM)
 
 // Differences in Differences
 gen DID=dfemp_M-dfemp_NM
 summarize dfemp_M dfemp_NM DID
 *DID: -3292.579*
 
 *According to this initial aproximation, we can say that China's entry to WTO had a negative effect on the employment in the manufacturing industry. More specifically, it costed 3292.579 jobs in that industry sector*
 
 *---5---*
 gen treat=post_china*manuf 
 reg emp manuf treat post_china
 
 *We get the same diff in diff estimate when we run the regression*
 
 **---6---*
 gen avgpay=qp1/emp
 reg est manuf treat post_china
 reg avgpay manuf treat post_china
 
 *We can see that China's entry to WTO did not have a significant effect on the number of establishments nor the average payment in the manufacturing sector. Although the coefficients are negative, they are not significant*
 
**---7---**
gen logemp=log(emp)
reg logemp manuf treat post_china

*In this regression we observe that China's entry in the WTO reduced 16.72% the employment in the manufacturing sector in net terms. It is necessary to take logs because the employment variable is not normally distributed. In addition to this, it allows a better interpretation of the results*

*---8---*
gen y98=1 if year == 1998
replace y98=0 if (y98 >= .)

gen y99=1 if year == 1999
replace y99=0 if (y99 >= .)

gen y00=1 if year == 2000
replace y00=0 if (y00 >= .)

gen y01=1 if year == 2001
replace y01=0 if (y01 >= .)

gen y02=1 if year == 2002
replace y02=0 if (y02 >= .)

gen y03=1 if year == 2003
replace y03=0 if (y03 >= .)

gen y04=1 if year == 2004
replace y04=0 if (y04 >= .)

gen y05=1 if year == 2005
replace y05=0 if (y05 >= .)

gen y06=1 if year == 2006
replace y06=0 if (y06 >= .)

gen int98=y98*manuf
gen int99=y99*manuf
gen int00=y00*manuf
gen int01=y01*manuf
gen int02=y02*manuf
gen int03=y03*manuf
gen int04=y04*manuf
gen int05=y05*manuf
gen int06=y06*manuf

*---9---*
reghdfe logemp y98 y99 y00 y01 y02 y03 y04 y05 y06 int99 int00 int01 int02 int03 int04 int05 int06, absorb(naics fipstate)

*In this regression we observe that China's entry to the WTO had a negative effect on employment in the manufacturing sector since the first year (2001). Nevertheless, we can see that its effect increases over time: in 2001, its impact was the loss of 13.83% of jobs in net terms, in 2002 this number amounts to 19.72%; in 2003, to 34.71%; in 2004, to 35.28%; in 2005, to 36.97%; and in 2006, the effect was the loss of 41.83% of jobs in net terms. Due to this, we can say that the China shock had a significant negative effect on employment specially on the long-run. For the years 1999 and 2000, we should not expect to see any effect for the interaction term as China had not yet entered the WTO. For the year 1999 this is true, but we do see an effect for the year 2000. Although it is not possible to say that this result is caused directly by the entrance of China to the WTO, it could be argued that the inminent entrance of China to the organization (which was approved in 1999) discouraged investment in manufacture. Another possible explanation for that coefficient could be that that year some other domestic or international event affected the manufacturing industry.*

*---10---*
gen logest=log(est)

reghdfe logest y98 y99 y00 y01 y02 y03 y04 y05 y06 int99 int00 int01 int02 int03 int04 int05 int06, absorb(naics fipstate)

reghdfe avgpay y98 y99 y00 y01 y02 y03 y04 y05 y06 int99 int00 int01 int02 int03 int04 int05 int06, absorb(naics fipstate)

*In this analysis we can see that although China's entry to the WTO did not have a significant effect on employment in the first year (2001), it did have it since the year following the entry: in 2002, it caused the loss of 10% of establishments in net terms; in 2003, the loss was of 10.67% of establishments; in 2004, of 12.30%; in 2005, of 15.47%; in 2006, of 16.18%. For this reason we can also say that the effect increased over time. In contrast, in regards to the average payment in the manufacturing industry, the China shock had no significant effects in any of the years.*

*---Close log-file---*
log close


*================
* PROBLEM 2
*================
clear all
cls

*---log-file---*
log using "C:\PUCP\Econometría Avanzada Aplicada\Problem set\problem_2.log", replace

/*-------------*/
/* Import data */
/*-------------*/
use "C:\PUCP\Econometría Avanzada Aplicada\Problem set\eitc.dta", clear


**---1---**
summarize

**---2---**
//single women with no children
mean if children==0 

//single women with 1 child
mean if children==1 

//single women with 2+ children
mean if children>=2 

**---3---**
*Treatment group: woman with kids(anykids=1)*
*Control group: woman without kids (anykids=0)*
*Intervention time: year 1994*

//treatment
gen anykids=.
replace anykids = 1 if children >=1
replace anykids = 0 if children < 1

//dummy for time variable
gen post93=.
replace post93 = 1 if year >=1994
replace post93 = 0 if year < 1994

**---4---**
*y= earn

//Interaction term
gen interaction = anykids*post93

// Regression Estimation¡
 reg earn anykids post93 interaction 
 est store reg1
 
 *We can see in coefficient of the interaction the number 1668 that express our DID.
 *To test manually the regression, we decided to repeat the proccess again including a new way of build the regression.
 
//

gen earn2= earn if post93 ==1

gen earn1= earn if post93 ==0
 
 // Average Employment NJ pre 
 egen earn_con1=mean(earn1) if anykids==1 
 // Average Employment NJ post
 egen earn_con2=mean(earn2) if anykids==1 
 // Average Employment PA pre 
 egen earn_sin1=mean(earn1) if anykids==0  
 // Average Employment PA post 
 egen earn_sin2=mean(earn2) if anykids==0  
 // Diferencia de mujeres que tienen hijos post y pre
 gen df_con=earn_con2-earn_con1
 // Diferencia de mujeres que no tienen hijos post y pre
 gen df_sin=earn_sin2-earn_sin1
 
 
 egen df_con_M=max(df_con)
 egen df_sin_M=max(df_sin)
 
 // Differences in Differences
 gen DID=df_con_M-df_sin_M
 summarize df_con_M df_sin_M DID
 *DID: 1668.678*

*The results shows that the policy have possitive and significant effects in earn. As we can see in the results of the DID in the column of the mean we got the number 1668.67 for DID. In that way, we can conclude that both regressions are correct and have a positive effect in our variable of earnings. Another important thing is that both present a p-value of (0.009), which reflects that both have significance. 
 
**---5---**
reg earn anykids post93 interaction i.state i.year
est store reg2

*As we can see in the results, this new regression change a little bit with the previous one and present significance (0.007). This new number of the coefficient of the interaction is 1612.13 that is lower than the result of the previous excercise 1668.678. Also in this regression we could find in the analysis between the years that in even previous years of the treatment and even on 1994 the effect was has a negative coefficient for 1991-1994, but in 1995 this change to postive. This last results don't have significance when we watch the p.value on them.

**---6---**
// Controlling for chain and onwership  
  reg earn anykids post93 interaction i.state i.year urate nonwhite age ed unearn
  est store reg3
  esttab reg1 reg2 reg3, se title("Replication of Eissa, Nada and Liebman paper") 

  *As we can see in the table, our regressions vary between 1668.7 (1º); 1612.13 (2º); and 1661.78 (3º). All of them present significance on their p.value (as we mention in each excercise). In that way, we can conclude that our regressions don't present a big difference including new fixed efeccts and controls variables. 


**---7---** 
gen kids=.
replace kids = 1 if children >1
replace kids = 0 if children == 1

//interaction_1
gen interaction_1 = kids*post93

// Regression Estimation
 //reg y x
 reg earn kids post93 interaction_1 
 est store reg4

/*The results shows that the policy have negative effects on earn for women with 1 or 2+ children. One possible reason is the sustituion effects: the credit subsidizes the worker's wage so that the substitution effect encourages additional hours while the income effect causes hours to decrease. Is possible that women with more children would prefer to reduce their salary spending more time at home but replacing that effect with the EITC.
 */
 
**---8---**
gen placebo=.
replace placebo = 1 if year <=1993
replace placebo = 0 if year > 1993

gen interaction_2 = anykids*placebo

// Regression Estimation
 //reg y x
 reg earn anykids placebo interaction_2
 est store reg5

* If we estimate a Placebo tratment, we find that our result are NOT significant. So we can say that our results are reassuring, because we can confirm the effect of the EITC on earn and discard a economy tendency.

*---Close log-file---*
log close
