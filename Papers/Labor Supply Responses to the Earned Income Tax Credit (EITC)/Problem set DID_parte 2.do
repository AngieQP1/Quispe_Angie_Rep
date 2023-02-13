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