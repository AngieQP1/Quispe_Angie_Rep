
*Problem set DID preg 2
*Angs

use "C:\Users\MSI\Desktop\QLAB\Econometria Aplicada\Cris Tello\Problem set\eitc.dta", clear

*1.Create a table summarizing all the data provided in the data set.

summarize

*2.Calculate the sample means of
 
//single women with no children
mean if children==0 

//single women with 1 child
mean if children==1 

//single women with 2+ children
mean if children>=2 

*3.Construct a variable for the “treatment” called anykids (indicator for 1 or more kids) and a variable for time being after the expansion (called post93—should be 1 for 1994 and later)


//treatment
gen anykids=.
replace anykids = 1 if children >=1
replace anykids = 0 if children < 1


gen post93=.
replace post93 = 1 if year >=1994
replace post93 = 0 if year < 1994

*4.Using the “interaction term” diff-in-diff specification, run a regression to estimate the difference-in-differences estimate of the effect of the EITC program on earnings. Use all women with children as the treatment group.

/*fastfood.do
// Regression Estimation
 // cambios en el empleo en la tienda i en el estado s 
 gen cfte=fte2-fte
 //reg y x
 reg cfte state 
 est store reg1
*/


*5.Repeat (iv), but now include state and year fixed effects [Hint: state fixed effects, are included when we include a dummy variable for each state]. Do you get similar estimated treatment effects compared to (iv)?










