*GESTANTES QUE RECIBIERON SUPLEMENTO DE HIERRO


clear all

*Especificamos nuestra carpeta de trabajo
cd "C:\Users\MSI\Documents\Hechos estilizados\ENDES"

*Bajar y descomprimir los sgtes modulos:
*Modulo66\rec0111, 
*Modulo66\rec91, 
*Modulo67\re223132, 
*Modulo69\rec41, 

*Importamos las bases de datos
import dbase Modulo66\REC0111.dbf, clear
foreach v of var * {
	rename `v' `=lower("`v'")'
}
save 		 REC0111.dta, replace

import dbase Modulo66\REC91.dbf, clear
foreach v of var * {
	rename `v' `=lower("`v'")'
}
save 		 REC91.dta, replace

import dbase Modulo67\RE223132.dbf, clear
foreach v of var * {
	rename `v' `=lower("`v'")'
}
save 		 RE223132.dta, replace

import dbase Modulo69\REC41.dbf, clear
foreach v of var * {
	rename `v' `=lower("`v'")'
}
save 		 rec41.dta, replace

*Terminamos de importar


*Realizamos el merge de las bases de datos


use rec0111, clear
merge 1:1 caseid using "rec91", nogen
merge 1:1 caseid using "re223132", nogen
merge 1:m caseid using "rec41", nogen
save rec0111_rec91_re223132_rec41.dta, replace

use rec0111_rec91_re223132_rec41.dta, clear
*Factor de expansion
gen wt=v005/1000000


** Cálculo de la variable region natural
label define sregion 1 "Lima_Metropolitana" 2 "Resto_Costa" 3 "Sierra" 4 "Selva"
label values sregion sregion
label var sregion "region"
 
*Creamos las regiones por zonas
gen     dominio1=1 if sregion==1 & v025==1 
replace dominio1=2 if sregion==1 & v025==2
replace dominio1=3 if sregion==2 & v025==1
replace dominio1=4 if sregion==2 & v025==2
replace dominio1=5 if sregion==3 & v025==1
replace dominio1=6 if sregion==3 & v025==2

*Las regiones creadas
label define dominio1 1 "Costa urbana" 2 "Costa rural" 3 "Sierra urbana" ///
 4 "Sierra rural" 5 "Selva urbana" 6"Selva rural"
label values dominio1 dominio1

*-------------------------------------*
*Se crearon las variables demográficas
label list dominio1
label list sregion
*-------------------------------------*

***********************
*Creacion de variables*
***********************


*****************************************************************
* GENERANDO LA VARIABLE "GESTANTE TOMÓ O NO SUPLEMENTO DE HIERRO"
*****************************************************************

gene hierro_emb=0 if m13>=0 & m13<=98
replace hierro_emb=1 if m45==1 & hierro_emb==0
label define hierro_emb 1"Tomo hierro emb" 0"No tomo"
label values hierro_emb emb
label list hierro_emb
tab hierro_emb [iweight=wt]

tabulate hierro_emb  

*****************************************************************
* GENERANDO LA VARIABLE "TUVO O NO EXAMENES AUXILIARES"
*****************************************************************

gene exam_aux=1 if m42d==1 & m42e==1 & m42e!= . & m42d!= .
replace exam_aux=0 if exam_aux==. & m42e!= . & m42d!= .

tab exam_aux
tab exam_aux [iweight=wt]


************************************************************
* GENERAMOS LA VARIABLE "NRO DE CONTROLES PRE NATALES" 
************************************************************

*recode m14 (0 thru 5=2)( 6 thru 50=1) into N_CPN
*if (m14=98 | (missing(m14) & not(sysmis(m14)) ) ) N_CPN=8
*if (m14=0) N_CPN =3
*val label N_CPN 1 '6 o mas veces' 2 'menos de 6' 3 'Sin CPN' 8 'no sabe /sin informacion' 

gen	n_cpn = 0 if m14>=0 & m14<=5  & m19<.
replace n_cpn=1 if  m14>=6 &  m14<=50 & m19<.
replace n_cpn=. if m14>50 | m14==. 
label define controles  1"6 o mas veces" 0"menos de 6"
label values n_cpn controles
label variable n_cpn "Numero de controles pre natales"


***TAB ncpn****
tab n_cpn [iweight=wt]


***********************************************************
* GENERANDO LA VARIABLE "PARTO INSTITUCIONAL"
************************************************************

gene parto_inst=1 if m15==21|m15==22|m15==23|m15==24|m15==25|m15==26|m15==31|m15==32 & m15!= .
replace parto_inst=0 if m15==11|m15==12|m15==13|m15==33|m15==96 & m15!= .
label define parto 1"Establecimiento Salud" 0"Otro lugar"
label values parto_inst parto

gene parto_minsa=1 if m15==21|m15==24|m15==25 & m15!= .
replace parto_minsa=0 if m15==11|m15==22|m15==23|m15==26|m15==31 |m15==32|m15==33|m15==96 & m15!= .
label define part 1"Establecimiento Minsa" 0"Otro lugar"
label values parto_minsa part

tab parto_minsa [iweight=wt]


*********************************
*  CREACIÓN DEL INDICE PISG 
*********************************

*Mujeres que accedio a 0 o más servicios 

gen  PISG=.
replace PISG=0 if parto_minsa+n_cpn+exam_aux+hierro_emb==0
replace PISG=1 if parto_minsa+n_cpn+exam_aux+hierro_emb==1
replace PISG=2 if parto_minsa+n_cpn+exam_aux+hierro_emb==2
replace PISG=3 if parto_minsa+n_cpn+exam_aux+hierro_emb==3
replace PISG=4 if parto_minsa+n_cpn+exam_aux+hierro_emb==4
label define PISG 0"0" 1"1" 2"2" 3"3" 4"4"

label values PISG PISG
label var PISG "# de servicios del paquete integrado de salud para la gestante"

tab PISG

*******************
*UMBRAL 3 Ó MÁS****
*******************
gen PISG_index=.
replace PISG_index=0 if parto_minsa+n_cpn+exam_aux+hierro_emb<=2
replace PISG_index=1 if parto_minsa+n_cpn+exam_aux+hierro_emb>=3
label define PISG_index 0"No" 1"Sí"

label values PISG_index PISG_index
label var PISG_index "Madre accede a 3 o más servicios"

*********************************
*  GRÁFICOS OVER PISG 
*********************************

*GRAFICO DE BARRA OVER PISG, SEGÚN NÚMERO DE SERVICIOS
*Graph 1
 graph bar, over(PISG) title("% de mujeres que acceden", size(medium))

*GRAFICO DE BARRA OVER PISG, ACCEDE AL PAQUETE
*Graph 2
 graph bar, over(PISG_index) title("% de mujeres que acceden", size(medium))

*GRAFICO DE BARRA OVER PISG, ACCEDE AL PAQUETE, SEGÚN ZONA
graph bar, over(PISG) over(dominio1)  //
          title("% de mujeres que acceden", size(medium)) //
		  legend(size(minuscule) position(1) span)

********************************
*Caracteristicas****************
********************************
		  
*Grupos de edad
gen          dv_age = v013
label define dv_age 1 "15-19" 2 "20-24" 3 "25-29" 4 "30-34" 5 "35-39" 6 "40-44" 7 "45-49"
label values dv_age dv_age
label var    dv_age "Grupos de edad"
	  
*zonas
label define v025 1 "Urbano" 2 "Rural"
label values v025 v025

*Nivel de ingreso
label define v190 1 "Quintil inferior" 2 "Segundo quintil" 3 "Quintil intermedio" ///
 4 "Cuarto quintil" 5 "Quintil superior"
label values v190 v190

*Nivel educativo
recode v106 (0 1=1 "Sin nivel/Primaria") (2=2 "Secundaria") /// 
 (3=3 "Superior") if v012>14, gen(edu_madre)

*Lengua materna

recode s119 (1/9=1 "Lengua Nativa") (10/10=2 "Castellano") (11/12=3 "Otro"), gen(l_materna)


*TABLAS*

*por EDUCA
tab PISG_index  edu_madre [iweight=wt], nofreq cell

*ZONA URB RUR
tab PISG_index  v025 [iweight=wt], nofreq cell

*NIVEL DE INGRESO
tab PISG_index  v190 [iweight=wt], nofreq cell

*L MATERNA
tab PISG_index  l_materna [iweight=wt], nofreq cell


*L MATERNA
tab   dv_age PISG_index [iweight=wt], nofreq cell

*frecuencia del paquete  accede o no
tab1 PISG [iweight=wt]