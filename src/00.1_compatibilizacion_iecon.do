clear all
use "ech_2019_raw_ine.dta"

*-------------------------------------------------------------------------------
* 2) correc_datos.do
cap rename e45_1__a e45_1_1_1
cap rename e45_1__b e45_1_2_1
cap rename e45_2__a e45_2_1_1
cap rename e45_2__b e45_2_2_1
cap rename e45_3__a e45_3_1_1
cap rename e45_3__b e45_3_2_1
cap rename e45_4__a e45_4_3_1
cap rename e45_5__a e45_5_1_1

cap rename g148_1_a g148_1_10
cap rename g148_1_b g148_1_11
cap rename g148_1_c g148_1_12
cap rename g148_2_a g148_2_10
cap rename g148_2_b g148_2_11
cap rename g148_2_c g148_2_12


cap rename ytdop ine_ytdop
cap rename ytdos ine_ytdos
cap rename ytinde ine_ytinde
cap rename ytransf ine_ytransf
cap rename pt1 ine_pt1
cap rename pt2 ine_pt2
cap rename pt4 ine_pt4
cap rename ht13 ine_ht13
cap rename yhog ine_yhog
cap rename ysvl ine_ysvl
cap rename mes bc_mes
cap rename anio bc_anio
cap rename dpto bc_dpto
cap rename ccz bc_ccz
recode bc_ccz (0=-9)

recode mto_cuot (.=0)  
recode mto_emer (.=0)
recode mto_hogc (.=0)

destring region_4, replace
destring bc_dpto, replace
destring bc_mes, replace
destring bc_anio, replace
destring bc_ccz, replace
destring f72_2, replace force
destring f91_2, replace

* 3) compatibilizacion_mod_1_4.do

rename numero bc_correlat
rename nper bc_nper
rename pesoano bc_pesoan

g bc_area=.
replace bc_area=1 if region_4==1 
replace bc_area=2 if region_4==2 
replace bc_area=3 if region_4==3 
replace bc_area=4 if region_4==4 

cap drop bc_filtloc
g bc_filtloc=(region_4<3)
recode bc_filtloc (0=2)


g bc_pe2=e26


g bc_pe3=e27


g bc_pe4=-9
	replace bc_pe4=1 if e30==1
	replace bc_pe4=2 if e30==2
	replace bc_pe4=3 if e30==3 | e30==4 | e30==5
	replace bc_pe4=4 if e30==7 | e30==8
	replace bc_pe4=5 if e30==6 | e30==9 | e30==10 | e30==11 | e30==12
	replace bc_pe4=6 if e30==13
	replace bc_pe4=7 if e30==14



g bc_pe5=-9
	replace bc_pe5=1 if e35==2 | e35==3
	replace bc_pe5=2 if e35==4 | e35==5
	replace bc_pe5=3 if e35==0 & (e36==1 | e36==2 | e36==3)
	replace bc_pe5=4 if e35==0 & (e36==4 | e36==6)
	replace bc_pe5=5 if e35==0 & (e36==5)


g bc_pe6a=-15
	replace bc_pe6a=4 if (e45_1==1 & (e45_1_1!=1 | e45_1_1!=4)) | e45_4==1 | e45_5==1 | e45_6==1
	replace bc_pe6a=2 if e45_2==1 & e45_2_1!=1 & e45_2_1!=6
	replace bc_pe6a=3 if (e45_1==1 & (e45_1_1==1 | e45_1_1==4)) | (e45_2==1 & (e45_2_1==1 |e45_2_1==6)) | (e45_3==1 & (e45_3_1==1 | e45_3_1 ==6))
	replace bc_pe6a=5 if ((e45_3==1 & (e45_3_1!=1 | e45_3_1!=6)) | e46==1) & bc_pe6a!=3
	replace bc_pe6a=1 if e45_1==2 & e45_2==2 & e45_3==2 & e45_4==2 & e45_5==2 & e45_6==2 & e46==2

g bc_pe6a1=-15
	replace bc_pe6a1=1 if bc_pe6a==3 & ((pobpcoac==2 & (f82==1|f96==1)) | pobpcoac==5)
	replace bc_pe6a1=2 if bc_pe6a==3 & bc_pe6a1!=1
	replace bc_pe6a1=-9 if bc_pe6a!=3

recode bc_pe6a (2/3=2) (4=3) (5=4), gen(bc_pe6b)
replace bc_pe6b=-9 if bc_pe6a==3

g bc_pe11=2 
	replace bc_pe11=1 if (e193==1|e197==1|e201==1|e212==1|e215==1|e218==1|e221==1|e224==1) 
	replace bc_pe11=-9 if bc_pe3<3 & bc_pe3!=.


g bc_pe12=e49
	replace bc_pe12=-9 if (e193==1|e197==1|e201==1|e212==1|e215==1|e218==1|e221==1|e224==1) 
	replace bc_pe12=-9 if bc_pe3<3 & bc_pe3!=.

	
g bc_pe13=-13


g bc_nivel=-15

replace bc_nivel=0 if bc_pe11==0 & bc_pe12==0 
replace bc_nivel=0 if ((e51_2==0 & e51_3==0) | ((e193==1 | e193==2) & e51_2==9))  

replace bc_nivel=1  if ((((e51_2>0 & e51_2<=6) | (e51_3>0 & e51_3<=6)) &  e51_4==0) | (e51_2==6 & e51_4==9))

replace bc_nivel=2  if  ((((e51_4>0 & e51_4<=3) | (e51_5>0 & e51_5<=3) | (e51_6>0 & e51_4<=6)) & (e51_7==0 & e51_8==0 & e51_9==0 & e51_10==0)) | (e51_7!=0 & e51_7_1==3) | (e51_4==3 & e51_8==9) | (e51_5==3 & e51_8==9)) 
 
replace bc_nivel=3  if  ((e51_7>0 &  e51_7<=9 & e51_7_1<3) | (e51_7!=0 & e51_4==0 & e51_5==0 & e51_6==0) & e51_8==0 & e51_9==0 & e51_10==0 )

replace bc_nivel=4  if (e51_8>0 & e51_8<=5) &  e51_9==0 &  e51_10==0 &  e51_11==0 

replace bc_nivel=5  if ((e51_9>0 & e51_9<=9) | (e51_10>0 & e51_10<=9) | (e51_11>0 & e51_11<=9)) 
replace bc_nivel=0 if bc_nivel==-15 & (e51_2==9 | e51_3==9)


g bc_edu=-15


replace bc_edu=0 if bc_nivel==0
replace bc_edu= e51_2 if bc_nivel==1 & ((e51_2>=e51_3 & e51_2!=9) | (e51_2>0 & e51_2!=9 & e51_3==9))
replace bc_edu= e51_3 if bc_nivel==1 & ((e51_3>e51_2 & e51_3!=9)  | (e51_3>0 & e51_3!=9 & e51_2==9))


replace bc_edu=6+e51_4 if bc_nivel==2 & e51_4<=3 & e51_4>0
replace bc_edu=9+e51_5 if bc_nivel==2 & e51_4==3 & e51_5<9 & e51_5>0
replace bc_edu=9+e51_6 if bc_nivel==2 & e51_4==3 & e51_6<9 &  e51_6>0
replace bc_edu=9 if bc_nivel==2 & e51_4>0 &  e51_5==0 & e51_6==0  & e201_1==1
replace bc_edu=9 if bc_nivel==2 & e51_4==3 & e51_5==9
replace bc_edu=12 if bc_nivel==2 & e51_4==3 & e51_5==9 & e212_1==1
replace bc_edu=9 if bc_nivel==2 & e51_4==3 & e51_6==9
replace bc_edu=12 if bc_nivel==2 & e51_4==3 & e51_6==9 & e212_1==1
replace bc_edu=6 if bc_nivel==2 & e51_4==9 
replace bc_edu=9 if bc_nivel==2 & e51_4==9 & e201_1==1
replace bc_edu=9+e51_5 if bc_edu==. & bc_nivel==2  & e51_5!=0
replace bc_edu=9+e51_6 if bc_edu==. & bc_nivel==2 

replace bc_edu=6+e51_7 if bc_nivel==3 & e51_7<9
replace bc_edu=6 if bc_nivel==3 & e51_7==9


replace bc_edu=e51_8+12 if bc_nivel==4 & e51_8<9 & e51_8>0
replace bc_edu=12 if bc_nivel==4 & e51_8==9
replace bc_edu=15 if bc_nivel==4 & e51_8==9 & e215_1==1


replace bc_edu=e51_9+12 if bc_nivel==5 & e51_9<9  &  e51_9>0
replace bc_edu=e51_10+12 if bc_nivel==5 & e51_10<9  &  e51_10>0
replace bc_edu=e51_11+12+e51_9 if bc_nivel==5 & e51_11<9 & e51_11>0 & e51_9>=e51_10 
replace bc_edu=e51_11+12+e51_10 if bc_nivel==5 & e51_11<9 & e51_11>0 & e51_9<e51_10
replace bc_edu=12 if bc_nivel==5 & e51_9==9
replace bc_edu=12 if bc_nivel==5 & e51_10==9
replace bc_edu=15 if bc_nivel==5 & e51_9==9 & e218_1==1
replace bc_edu=16 if bc_nivel==5 & e51_10==9 & e218_1==1
replace bc_edu=12+e51_9 if bc_nivel==5 & e51_11==9  & e51_9>=e51_10
replace bc_edu=12+e51_10 if bc_nivel==5 & e51_11==9  & e51_9<e51_10 

recode bc_edu 23/38=22


g bc_finalizo=-13


g bc_pobp = pobpcoac
recode bc_pobp (10=9)


g bc_pf41a=f73
	replace bc_pf41a=7 if f73==8
	replace bc_pf41a=-9 if f73==0

g bc_cat2=-9
	replace bc_cat2=1 if f73==1
	replace bc_cat2=2 if f73==2
	replace bc_cat2=3 if f73==4
	replace bc_cat2=4 if f73==5|f73==6
	replace bc_cat2=5 if f73==3|f73==7|f73==8
	
g bc_pf081=-9
	replace bc_pf081=1 if (f77==1 | f77==2 | f77==3) 
	replace bc_pf081=2 if (f77==5 | f77==6 | f77==7) 

g bc_pf082a=-9
	replace bc_pf082a=1 if f77==1
	replace bc_pf082a=2 if f77==2
	replace bc_pf082a=3 if f77==3

destring f72_2, replace
g bc_pf40=f72_2

g bc_rama=-9
	replace bc_rama=1 if f72_2>0000 & f72_2<1000
	replace bc_rama=2 if f72_2>1000 & f72_2<3500
	replace bc_rama=3 if f72_2>3500 & f72_2<3700
	replace bc_rama=4 if f72_2>4000 & f72_2<4500
	replace bc_rama=5 if (f72_2>=4500&f72_2<4900)|(f72_2>=5500&f72_2<5700)
	replace bc_rama=6 if (f72_2>=4900&f72_2<5500)|(f72_2>=5800&f72_2<6400)
	replace bc_rama=7 if f72_2>=6400&f72_2<8300
	replace bc_rama=8 if f72_2>=8300&f72_2<9910 | (f72_2>= 3700 & f72_2<=3900)


destring f71_2, replace
g bc_pf39=f71_2
	replace bc_pf39=-9 if bc_pf39==.&bc_pobp!=2
	replace bc_pf39=-15 if bc_pf39==.&bc_pobp==2
	
cap drop pf39aux
g pf39aux=bc_pf39
	replace pf39aux=0 if bc_pf39>0 & bc_pf39<130

cap drop bc_tipo_ocup
g bc_tipo_ocup=trunc(pf39aux/1000)
	replace bc_tipo_ocup=-9 if bc_tipo_ocup==0&bc_pobp!=2
drop pf39aux


g bc_pf07=f70
recode bc_pf07 (0=-9)


g bc_horas_hab=f85+f98 
recode bc_horas_hab (0=-9)
g bc_horas_hab_1=f85   
recode bc_horas_hab_1 (0=-9)

g bc_horas_sp=-13 
g bc_horas_sp_1=-13 

g bc_pf04=f69
recode bc_pf04 (3=4) (4=3) (5/6=4) (0=-9)

g bc_pf21= f107 
recode bc_pf21 (0=-9)

g bc_pf22=f108 
recode bc_pf22 (1=4) (2=1) (3=2) (4=3) (5/6=4) (0=-9)

g bc_pf26=f113
replace bc_pf26=-9 if bc_pobp<3|bc_pobp>5

g bc_pf34=f122
recode bc_pf34 (1=2) (2=1) (4/9=3) (0=-9)

g bc_reg_disse=-9
	replace bc_reg_disse=2 if bc_pobp==2
	replace bc_reg_disse=1 if (e45_1_1==1 | e45_2_1==1 | e45_3_1==1 | bc_pf41a==2) & bc_pobp==2

g bc_register=-9
	replace bc_register=2 if bc_pobp==2
	replace bc_register=1 if bc_pobp==2&f82==1

g bc_register2=-9
	replace bc_register2=2 if bc_pobp==2
	replace bc_register2=1 if bc_pobp==2&(f82==1|f96==1)


g bc_subocupado=-9
	replace bc_subocupado=2 if bc_pobp==2
	replace bc_subocupado=1 if f102==1&f104==5&bc_horas_hab>0&bc_horas_hab<40&bc_horas_hab!=.

g bc_subocupado1=-9
	replace bc_subocupado1=2 if bc_pobp==2
	replace bc_subocupado1=1 if (f101==1|f102==1)&f103==1&f104==5&f105!=7&bc_horas_hab>0&bc_horas_hab<40&bc_horas_hab!=.
	
save "ech_2019_iecon.dta", replace















