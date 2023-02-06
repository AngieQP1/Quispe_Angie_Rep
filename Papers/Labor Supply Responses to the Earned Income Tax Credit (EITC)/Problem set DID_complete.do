
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

*y= earn
*x= interaction

gen interaction = anykids*post93

// Regression Estimation
 //reg y x
 reg earn interaction 
 est store reg1

*5.Repeat (iv), but now include state and year fixed effects [Hint: state fixed effects, are included when we include a dummy variable for each state]. Do you get similar estimated treatment effects compared to (iv)?

reg earn interaction i.state i.year
est store reg2

*Se modifica los resultados de -2243 a -5004.17.


*6.Using the specification from (v), re-estimate this model including urate nonwhite age ed unearn, as well as state and year FEs as controls. Do you get similar estimated treatment effects compared to (v)?

// Controlling for chain and onwership  
  reg earn interaction i.state i.year urate nonwhite age ed unearn
  est store reg3
  esttab reg1 reg2 reg3, se title("Replication of Eissa, Nada and Liebman paper") 

  *Como se observa en el gráfico los coeficientes varían significativamente al momento de controlar bajo las variables señaladas. Esta variación se despliega de -2243.7 (1°regresión); -5004.2 (2°regresión); y -4173.3 (3°regresión).


*7. Estimate a version of your model that allows the treatment effect to vary by those with 1 or 2+ children. Include all other variables as in (vi). 

gen kids=.
replace kids = 1 if children >1
replace kids = 0 if children == 1

//interaction_1
gen interaction_1 = kids*post93

// Regression Estimation
 //reg y x
 reg earn interaction_1 
 est store reg4

*Se modifica los resultados de -2243 a -1128.242.
 
 
*8 Estimate a “placebo” treatment model 

gen post92=.
replace post92 = 1 if year >=1993
replace post92 = 0 if year < 1993

gen interaction_2 = anykids*post92

// Regression Estimation
 //reg y x
 reg earn interaction_2
 est store reg5

* If we estimate a Placebo tratment, we find that our result are -1128.242. 



