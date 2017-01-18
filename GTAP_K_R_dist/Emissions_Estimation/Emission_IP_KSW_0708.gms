***** Emissions regarding non-combustion (Indsutral processes, agriculture,LUCF, waste, etc.)

*CO2, CH4, N20, HFCs, PFCs, SF6 6개에 대해서 set정의
set GHGs /CO2, CH4, N2O, HFCs, PFCs, SF6/;

*농업(a_), 폐기물(w_), 산업공정(p_) 3개
set Emit_S
/p_total_co2,p_min_CO2,p_che_CO2,p_met_CO2,p_halo_co2,w_total_co2,p_total_ch4,w_inc_co2,p_che_ch4,p_halo_ch4,a_total_ch4,a_ferm_ch4,a_man_ch4, a_farm_ch4,a_res_ch4,w_total_ch4,w_land_ch4,w_wat_ch4,w_mis_ch4,p_total_n2o,p_che_n2o,p_halo_n2o,a_total_n2o,a_ferm_n2o,a_farm_n2o,a_res_n2o,w_total_n2o,w_wat_n2o,w_inc_n2o,w_mis_n2o,p_total_hfc,p_haloP_hfc,p_halo_hfc,p_total_pfc,p_halo_pfc,p_total_sf6,p_halo_sf6
/;

set tol_year(yeark) /1990/;

**READ** 온실가스 종합정보센터자료 읽기
Parameters Emit_GIR(yeark,Emit_S)  ;
$LIBINCLUDE XLIMPORT Emit_GIR emissions_estimation\GIR_Emissions.xlsx Emission!A6..AL47     ;

parameter Emit_Prcs(yeark,GHGs,i_sec0) non-combustion GHGs emissions by sources;

*******************************************
*광물생산(2.A)
*******************************************
Parameters Data_Clk(yeark), Data_Lst(yeark), Data_Dlm(yeark), Data_Sa(yeark)  ;
**READ** 클링커 생산량 (ton)
$LIBINCLUDE XLIMPORT Data_Clk emissions_estimation\GIR_Emissions.xlsx Production_of_minerals(2.A)!B3..AZ4     ;
**READ** 석회석 소비량 (ton)
$LIBINCLUDE XLIMPORT Data_Lst emissions_estimation\GIR_Emissions.xlsx Production_of_minerals(2.A)!B20..AZ21     ;
**READ** 백운석 소비량 (ton)
$LIBINCLUDE XLIMPORT Data_Dlm emissions_estimation\GIR_Emissions.xlsx Production_of_minerals(2.A)!B24..AZ25     ;
**READ** 소다회 소비량 (ton)
$LIBINCLUDE XLIMPORT Data_Sa emissions_estimation\GIR_Emissions.xlsx Production_of_minerals(2.A)!B38..AZ39     ;

Scalar Data_Clk_CCf, Data_Lst_CCf, Data_Dlm_CCf, Data_Sa_CCf   ;
**READ** 클링커 배출계수(tCO2/ton)
$LIBINCLUDE XLIMPORT Data_Clk_CCf emissions_estimation\GIR_Emissions.xlsx Production_of_minerals(2.A)!A7   ;
**READ** 석회석 배출계수(tCO2/ton)
$LIBINCLUDE XLIMPORT Data_Lst_CCf emissions_estimation\GIR_Emissions.xlsx Production_of_minerals(2.A)!B29   ;
**READ** 백운석 배출계수(tCO2/ton)
$LIBINCLUDE XLIMPORT Data_Dlm_CCf emissions_estimation\GIR_Emissions.xlsx Production_of_minerals(2.A)!B30   ;
**READ** 소다회 배출계수(tCO2/ton)
$LIBINCLUDE XLIMPORT Data_Sa_CCf emissions_estimation\GIR_Emissions.xlsx Production_of_minerals(2.A)!A42   ;

**클링커 소비에 따른 시멘트 부문 CO2 배출량 (ton CO2) (2.A.1)
** 0179 Cement (2005)=> 0148 Cement in 2010
Emit_Prcs(yeark,"CO2","0148") = Data_Clk(yeark) * Data_Clk_CCf ;
**백운석 소비에 따른 선철 부문 CO2 배출량 (ton CO2) (2.A.3)
** 0188 Pig iron (2005) =>0157 pig iron in 2010
Emit_Prcs(yeark,"CO2","0157") = Data_Dlm(yeark) * Data_Dlm_CCf ;
display Emit_Prcs;

**석회석 소비에 따른 선철 부문 CO2 배출량 추가 (ton CO2) (2.A.3)
** Since we have Prcs_ratio=0 in EE.gms, 'not Prcs_ratio' is valid
** CO2 in pig iron =CO2 using Dlm + CO2 using Lst * (Limeston in Pig iron)/(Limeston in Pig iron+Limeston in Other generation)
** In 2010, we should use co-generation instead of other generation
* CO2 in pig iron = CO2 from Dlm +CO2 from Limestone. CO2 from Limeston in pig iron =CO2 from limestone* money spent in Limeston used in pig iron/Limestone in pig iro+limestone in other generation
* in 2010 Limeston is 0033, pir iron is 0157 other generation is cogeneration 277 (No limestone in renewable?)
if(not Prcs_ratio,
*         Emit_Prcs("2009","CO2","0157") = 0;
         Emit_Prcs(t,"CO2","0157")$(not told(t)) = Emit_Prcs(t,"CO2","0157") + (Data_Lst(t) * Data_Lst_CCf) * (IOT_B0(t,"0033","0157")/(IOT_B0(t,"0033","0157")+IOT_B0(t,"0033","0277")+IOT_B0(t,"0033","0278")))   ;);
if(Prcs_ratio,
         loop(yeark$t(yeark),Emit_Prcs(yeark,"CO2","0157") = Emit_Prcs(yeark,"CO2","0157") + (Data_Lst(yeark) * Data_Lst_CCf) * (IOT_B0(yeark,"0033","0157")/(IOT_B0(yeark,"0033","0157")+IOT_B0(yeark,"0033","0277")+IOT_B0(yeark,"0033","0278"))););
** if IOT_B0(yeark, '0041','0188')=0 then use yeark+1 data
         loop(yeark$(not t(yeark) and (IOT_B0(yeark+1,"0033","0157"))), Emit_Prcs(yeark,"CO2","0157") = Emit_Prcs(yeark,"CO2","0157") + (Data_Lst(yeark) * Data_Lst_CCf) * (IOT_B0(yeark+1,"0033","0157")/(IOT_B0(yeark+1,"0033","0157")+IOT_B0(yeark+1,"0033","0277")+IOT_B0(yeark+1,"0033","0278"))););
** if IOT_B0(yeark, '0041','0188')=0 and yeark+1 data=0 use 2003 data
         loop(yeark$(not t(yeark) and (not IOT_B0(yeark+1,"0033","0157"))), Emit_Prcs(yeark,"CO2","0157") = Emit_Prcs(yeark,"CO2","0157") + (Data_Lst(yeark) * Data_Lst_CCf) * (IOT_B0("2003","0033","0157")/(IOT_B0("2003","0033","0157")+IOT_B0("2003","0033","0277")+IOT_B0("2003","0033","0278")));););

**석회석 소비에 따른 기타발전 부문 CO2 배출량 (ton CO2) (2.A.3)
if(not Prcs_ratio,
         Emit_Prcs(t,"CO2","0277")$(not told(t)) = (Data_Lst(t) * Data_Lst_CCf) * (IOT_B0(t,"0033","0277")/(IOT_B0(t,"0033","0157")+IOT_B0(t,"0033","0277")+IOT_B0(t,"0033","0278")))   ; );
** CO2 in Other generation using Limestone = CO2 using Lst * (Limeston in Other generation)/(Limeston in Pig iron+Limeston in Other generation)
if(Prcs_ratio,
         loop(yeark$t(yeark),Emit_Prcs(yeark,"CO2","0277") = (Data_Lst(yeark) * Data_Lst_CCf) * (IOT_B0(yeark,"0033","0277")/(IOT_B0(yeark,"0033","0157")+IOT_B0(yeark,"0033","0277")+IOT_B0(yeark,"0033","0278"))););
         loop(yeark$(not t(yeark) and (IOT_B0(yeark+1,"0033","0157"))), Emit_Prcs(yeark,"CO2","0277") = (Data_Lst(yeark) * Data_Lst_CCf) * (IOT_B0(yeark+1,"0033","0277")/(IOT_B0(yeark+1,"0033","0157")+IOT_B0(yeark+1,"0033","0277")+IOT_B0(yeark+1,"0033","0278"))););
         loop(yeark$(not t(yeark) and (not IOT_B0(yeark+1,"0033","0157"))), Emit_Prcs(yeark,"CO2","0277") = (Data_Lst(yeark) * Data_Lst_CCf) * (IOT_B0("2003","0033","0277")/(IOT_B0("2003","0033","0157")+IOT_B0("2003","0033","0277")+IOT_B0("2003","0033","0278")));););

**소다회 소비에 따른 CO2 배출량 (ton CO2) (2.A.4) , 그러나 업종별로 할당하지 않음 -> 배출량 카운팅에서 제외.

**생석회 및 백운석 생산 과정에서 발생한 CO2 배출량 (ton CO2) (2.A.2) (CO2 광물생산 공정 CO2 배출량에서 2.A.1, 2.A.3, 2.A.4 차감하여 계산)
** 0179 Cement (2005)=> 0148 Cement in 2010
loop(yeark$(Emit_Prcs(yeark,"CO2","0148") and Emit_Prcs(yeark,"CO2","0157") and Emit_Prcs(yeark,"CO2","0277")and Emit_Prcs(yeark,"CO2","0278")),
** CO2 in ind 182 (Lime, gypsum. plaster products) = Mineral process CO2 -Clinker-Dlim-Other generation- SA
** 0182 Lime, gypsum. plaster products (2005)=> 0151 in 2010
Emit_Prcs(yeark,"CO2","0151") = Emit_GIR(yeark,"p_min_CO2") - Emit_Prcs(yeark,"CO2","0148") - Emit_Prcs(yeark,"CO2","0157") - Emit_Prcs(yeark,"CO2","0277")- Emit_Prcs(yeark,"CO2","0278") - (Data_Sa(yeark) * Data_Sa_CCf) ; );

*******************************************
*화학산업(2.B)   0152 Nitrogen compound 0145 Other basic organic chemicals
* In 2010, we use 0123 "Fertilzer and Nitrogen compound" and 0115 Other basic organic chemicals (intermediate organic chemical included)
*******************************************
**암모니아 생산시 배출되는 CO2 배출량 (ton CO2)  (2.B.1)
Emit_Prcs(yeark,"CO2","0123") = Emit_GIR(yeark,"p_che_CO2") ;

**질산 생산시 배출되는 N2O 배출량 (ton CO2단위로 환산)  (2.B.2)
if(not Prcs_ratio,
         Emit_Prcs(t,"N2O","0123")$(not told(t)) = Emit_GIR(t,"p_che_n2o") * XP_B0(t,"0123") / ( XP_B0(t,"0123") + XP_B0(t,"0115") ) ; );
**XP_B0 (Total demand in basic price). 145=Other basic chemicals, 152=Nitrogen compound (2005) =>123 Fertilzer and Nitrogen compound,
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"N2O","0123") =  Emit_GIR(yeark,"p_che_n2o") * XP_B0(yeark,"0123") / ( XP_B0(yeark,"0123") + XP_B0(yeark,"0115") ) ;);
         loop(yeark$(not t(yeark) and (XP_B0(yeark+1,"0123"))), Emit_Prcs(yeark,"N2O","0123") = Emit_GIR(yeark,"p_che_n2o") * XP_B0(yeark+1,"0123") / ( XP_B0(yeark+1,"0123") + XP_B0(yeark+1,"0115") ) ;);
         loop(yeark$(not t(yeark) and (not XP_B0(yeark+1,"0123"))), Emit_Prcs(yeark,"N2O","0123") = Emit_GIR(yeark,"p_che_n2o") * XP_B0("2003","0123") / ( XP_B0("2003","0123") + XP_B0("2003","0115") ) ;); );

**아디프산 생산시 배출되는 N2o 배출량 (ton CO2단위로 환산)  (2.B.3)
if(not Prcs_ratio,
         Emit_Prcs(t,"N2O","0115")$(not told(t)) = Emit_GIR(t,"p_che_n2o") * XP_B0(t,"0115") / ( XP_B0(t,"0123") + XP_B0(t,"0115") ) ; );
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"N2O","0115") =  Emit_GIR(yeark,"p_che_n2o") * XP_B0(yeark,"0115") / ( XP_B0(yeark,"0123") + XP_B0(yeark,"0115") ) ;);
         loop(yeark$(not t(yeark) and (XP_B0(yeark+1,"0123"))), Emit_Prcs(yeark,"N2O","0115") = Emit_GIR(yeark,"p_che_n2o") * XP_B0(yeark+1,"0115") / ( XP_B0(yeark+1,"0123") + XP_B0(yeark+1,"0115") ) ;);
         loop(yeark$(not t(yeark) and (not XP_B0(yeark+1,"0123"))), Emit_Prcs(yeark,"N2O","0115") = Emit_GIR(yeark,"p_che_n2o") * XP_B0("2003","0115") / ( XP_B0("2003","0123") + XP_B0("2003","0115") ) ;); );


Parameters Data_CB(yeark), Data_Et(yeark), Data_CEt(yeark), Data_St(yeark)  ;
**READ** 카본블랙 생산량 (ton)
$LIBINCLUDE XLIMPORT Data_CB emissions_estimation\GIR_Emissions.xlsx Production_of_chemicals(2.B)!B27..AZ28     ;
**READ** 에틸렌 생산량 (ton)
$LIBINCLUDE XLIMPORT Data_Et emissions_estimation\GIR_Emissions.xlsx Production_of_chemicals(2.B)!B43..AZ44     ;
**READ** 염화에틸렌 생산량 (ton)
$LIBINCLUDE XLIMPORT Data_CEt emissions_estimation\GIR_Emissions.xlsx Production_of_chemicals(2.B)!B59..AZ60     ;
**READ** 스틸렌 생산량 (ton)
$LIBINCLUDE XLIMPORT Data_St emissions_estimation\GIR_Emissions.xlsx Production_of_chemicals(2.B)!B75..AZ76     ;

Scalar Data_CB_CCf, Data_Et_CCf, Data_CEt_CCf, Data_St_CCf   ;
**READ** 카본블랙 배출계수(tCH4/ton)
$LIBINCLUDE XLIMPORT Data_CB_CCf emissions_estimation\GIR_Emissions.xlsx Production_of_chemicals(2.B)!A31   ;
**READ** 에틸렌 배출계수(tCH4/ton)
$LIBINCLUDE XLIMPORT Data_Et_CCf emissions_estimation\GIR_Emissions.xlsx Production_of_chemicals(2.B)!A47   ;
**READ** 염화에틸렌 배출계수(tCH4/ton)
$LIBINCLUDE XLIMPORT Data_CEt_CCf emissions_estimation\GIR_Emissions.xlsx Production_of_chemicals(2.B)!A63   ;
**READ** 스틸렌 배출계수(tCH4/ton)
$LIBINCLUDE XLIMPORT Data_St_CCf emissions_estimation\GIR_Emissions.xlsx Production_of_chemicals(2.B)!A79   ;

Scalar
GWP_CH4 CO2 of CH4 /21/
GWP_N2O CO2 of N2O /310/
;

** 0147 Basic inorganic chemical (2005) => 0117 (2010)
** 0142 "Petrochemical basic products" => 0111, 0112 (2010)
** 0143 "Petrochemical intermediate products" => 0113 (2010)

**카본블랙 생산에 따른 CH4 배출량 (ton CO2단위로 환산) (2.B.5) 147="Basic inorganic chemicals"
Emit_Prcs(yeark,"CH4","0117") = Data_CB(yeark) * Data_CB_CCf * GWP_CH4 ;

**에틸렌 및 스틸렌 생산에 따른 CH4 배출량 (ton CO2단위로 환산) (2.B.5) 142="Petrochemical basic products"
** We split this into 0111 and 0112 in 2010 using XP_B0
Emit_Prcs(yeark,"CH4","0111") = (Data_Et(yeark) * Data_Et_CCf * GWP_CH4 + Data_St(yeark) * Data_St_CCf * GWP_CH4)*XP_B0("0111")/(XP_B0("0111")+XP_B0("0112"));
Emit_Prcs(yeark,"CH4","0112") = (Data_Et(yeark) * Data_Et_CCf * GWP_CH4 + Data_St(yeark) * Data_St_CCf * GWP_CH4)*XP_B0("0112")/(XP_B0("0111")+XP_B0("0112"));

**염화에틸렌 생산에 따른 CH4 배출량 (ton CO2단위로 환산) (2.B.5) 143="Petrochemical intermediate products"
Emit_Prcs(yeark,"CH4","0113") = Data_CEt(yeark) * Data_CEt_CCf * GWP_CH4 ;
$ontext
loop(yeark$(Emit_Prcs(yeark,"CH4","0147") and Emit_Prcs(yeark,"CH4","0142") and Emit_Prcs(yeark,"CH4","0143") ),
if (abs(Emit_Prcs(yeark,"CH4","0147")  + Emit_Prcs(yeark,"CH4","0142") + Emit_Prcs(yeark,"CH4","0143") - Emit_GIR(yeark,"p_che_ch4")) > 0.001 , Abort "Check the 2.B" ); );

loop(yeark$(Emit_Prcs(yeark,"CO2","0152") ),
if( abs( Emit_Prcs(yeark,"CO2","0152") + Emit_Prcs(yeark,"N2O","0152") + Emit_Prcs(yeark,"N2O","0145") -  Emit_GIR(yeark,"p_che_CO2") -  Emit_GIR(yeark,"p_che_N2O") ) > 0.001, Abort "Check the 2.B" ); );
$offtext
*******************************************
*금속생산(2.C)
*******************************************

Parameters Data_CE(yeark) ;
**READ** 탄소전극봉 수입량 (ton)
$LIBINCLUDE XLIMPORT Data_CE emissions_estimation\GIR_Emissions.xlsx Production_of_metals(2.C)!B3..AZ4     ;

Scalar Data_CE_CCf ;
**READ** 탄소전극봉 배출계수(tCO2/ton)
$LIBINCLUDE XLIMPORT Data_CE_CCf emissions_estimation\GIR_Emissions.xlsx Production_of_metals(2.C)!A7   ;

**탄소전극붕 소비에 따른 CO2 배출량 (ton CO2) (2.C.1) 배분. 총거래표가 아닌 수입거래표 상의 기타 전기장치 투입비율에 따라 배분하였음. 이는 탄소전극봉의 수입량을 기초로 하기 때문임.
**탄소전극붕 소비에 따른 조강 CO2 배출량 (ton CO2) (2.C.1)   "0247(misc electroni equipment" in "0190"(Steel ingot), "0191"(Steel lods), "0192"(Section Steel)
** in 2010
*"0247(misc electroni equipment" =>0223
*"0190"(Steel ingot)=> 0159,
*"0191"(Steel lods)=>0160,
*"0192"(Section Steel)=>0161

if(not Prcs_ratio,
         Emit_Prcs(t,"CO2","0159")$(not told(t)) = Data_CE(t) * Data_CE_CCf *
         IOT_BM0(t,"0223", "0159") / ( IOT_BM0(t,"0223", "0159") + IOT_BM0(t,"0223", "0160") + IOT_BM0(t,"0223", "0161") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"CO2","0159") = Data_CE(yeark) * Data_CE_CCf *
         IOT_BM0(yeark,"0223", "0159") / ( IOT_BM0(yeark,"0223", "0159") + IOT_BM0(yeark,"0223", "0160") + IOT_BM0(yeark,"0223", "0161") ) ;);
         loop(yeark$(not t(yeark) and (IOT_BM0(yeark+1,"0223", "0159"))),Emit_Prcs(yeark,"CO2","0159") = Data_CE(yeark) * Data_CE_CCf *
         IOT_BM0(yeark+1,"0223", "0159") / ( IOT_BM0(yeark+1,"0223", "0159") + IOT_BM0(yeark+1,"0223", "0160") + IOT_BM0(yeark+1,"0223", "0161") ) ;);
         loop(yeark$(not t(yeark) and not IOT_BM0(yeark+1,"0223", "0159")), Emit_Prcs(yeark,"CO2","0159") = Data_CE(yeark) * Data_CE_CCf *
         IOT_BM0("2003","0223", "0159") / ( IOT_BM0("2003","0223", "0159") + IOT_BM0("2003","0223", "0160") + IOT_BM0("2003","0223", "0161") ) ;););

**탄소전극붕 소비에 따른 철근및봉강 CO2 배출량 (ton CO2) (2.C.1)
if(not Prcs_ratio,
         Emit_Prcs(t,"CO2","0160")$(not told(t)) = Data_CE(t) * Data_CE_CCf *
         IOT_BM0(t,"0223", "0160") / ( IOT_BM0(t,"0223", "0159") + IOT_BM0(t,"0223", "0160") + IOT_BM0(t,"0223", "0161") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"CO2","0160") = Data_CE(yeark) * Data_CE_CCf *
         IOT_BM0(yeark,"0223", "0160") / ( IOT_BM0(yeark,"0223", "0159") + IOT_BM0(yeark,"0223", "0160") + IOT_BM0(yeark,"0223", "0161") ) ;);
         loop(yeark$(not t(yeark) and (IOT_BM0(yeark+1,"0247", "0159"))), Emit_Prcs(yeark,"CO2","0160") = Data_CE(yeark) * Data_CE_CCf *
         IOT_BM0(yeark+1,"0223", "0160") / ( IOT_BM0(yeark+1,"0223", "0159") + IOT_BM0(yeark+1,"0223", "0160") + IOT_BM0(yeark+1,"0223", "0161") ) ;);
         loop(yeark$(not t(yeark) and not IOT_BM0(yeark+1,"0223", "0159")), Emit_Prcs(yeark,"CO2","0160") = Data_CE(yeark) * Data_CE_CCf *
         IOT_BM0("2003","0223", "0160") / ( IOT_BM0("2003","0223", "0159") + IOT_BM0("2003","0223", "0160") + IOT_BM0("2003","0223", "0161") ) ;););

**탄소전극붕 소비에 따른 형강 CO2 배출량 (ton CO2) (2.C.1)
if(not Prcs_ratio,
         Emit_Prcs(t,"CO2","0161")$(not told(t)) = Data_CE(t) * Data_CE_CCf *
         IOT_BM0(t,"0223", "0161") / ( IOT_BM0(t,"0223", "0159") + IOT_BM0(t,"0223", "0160") + IOT_BM0(t,"0223", "0161") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"CO2","0161") = Data_CE(yeark) * Data_CE_CCf *
         IOT_BM0(yeark,"0223", "0161") / ( IOT_BM0(yeark,"0223", "0159") + IOT_BM0(yeark,"0223", "0160") + IOT_BM0(yeark,"0223", "0161") ) ;);
         loop(yeark$(not t(yeark) and (IOT_BM0(yeark+1,"0223", "0161"))), Emit_Prcs(yeark,"CO2","0161") = Data_CE(yeark) * Data_CE_CCf *
         IOT_BM0(yeark+1,"0223", "0161") / ( IOT_BM0(yeark+1,"0223", "0159") + IOT_BM0(yeark+1,"0223", "0160") + IOT_BM0(yeark+1,"0223", "0161") ) ;);
         loop(yeark$(not t(yeark) and not IOT_BM0(yeark+1,"0223", "0161")), Emit_Prcs(yeark,"CO2","0161") = Data_CE(yeark) * Data_CE_CCf *
         IOT_BM0("2003","0223", "0161") / ( IOT_BM0("2003","0223", "0159") + IOT_BM0("2003","0223", "0160") + IOT_BM0("2003","0223", "0161") ) ;); );
** compare Non CO2 generated using emittor*emission coefficent (Emit_Prcs) and GIR stats (Emit_GIR). If the difference is large, then check the entire process
loop(yeark$(Emit_Prcs(yeark,"CO2","0159") and Emit_Prcs(yeark,"CO2","0160") and Emit_Prcs(yeark,"CO2","0161") and not tol_year(yeark)),
if (abs(Emit_Prcs(yeark,"CO2","0159")  + Emit_Prcs(yeark,"CO2","0160") + Emit_Prcs(yeark,"CO2","0161") - Emit_GIR(yeark,"p_met_CO2")) > 0.001 , Abort "Check the 2.C" ); );

*******************************************
*할로카본 및 육불화항 생산(2.E)  0146=Industrial gases
*******************************************
** in 2010 0146 "Industrial gases" => 0116
Emit_Prcs(yeark,"HFCs","0116") = Emit_GIR(yeark,"p_haloP_hfc") ;


*******************************************
*할로카본 및 육불화항 소비(2.F)  0224="Airconditioning/Refrigerator", "0229"=misc mach equip with general purpose, "0274"-"0277"=Auto
*******************************************

Parameters Data_HFC152a(yeark), Data_HFC123a(yeark) ;
**READ** HFC-152a 순수입량 (kg)
$LIBINCLUDE XLIMPORT Data_HFC152a emissions_estimation\GIR_Emissions.xlsx Consumption_of_halocarbons(2.F)!B2..AZ3     ;
**READ** HFC-134a 순수입량 (kg)
$LIBINCLUDE XLIMPORT Data_HFC123a emissions_estimation\GIR_Emissions.xlsx Consumption_of_halocarbons(2.F)!B5..AZ6     ;
* In 2010
*0224="Airconditioning/Refrigerator" =>0197
*"0229"=misc mach equip with general purpose,=>0200
*"0274"-"0277"=Auto=> 0249~0252

**할로카본 소비에 따른 공기조절장치 및 냉방장치 HFCs 배출량 (ton CO2단위로 환산) (2.F.1-2.F.6) "0224"
if(not Prcs_ratio,
         Emit_Prcs(t,"HFCs","0197")$(not told(t)) = ((Data_HFC152a(t) * 140 / 1000) + ( Data_HFC123a(t) * 1300 / 1000 )) *
         IOT_B0(t,"0116", "0197") / ( IOT_B0(t,"0116", "0200") + IOT_B0(t,"0116", "0197") + IOT_B0(t,"0116", "0249") + IOT_B0(t,"0116", "0250")+ IOT_B0(t,"0116", "0251")+ IOT_B0(t,"0116", "0252") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"HFCs","0197") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0(yeark,"0116", "0197") / ( IOT_B0(yeark,"0116", "0197") + IOT_B0(yeark,"0116", "0200") + IOT_B0(yeark,"0116", "0249") + IOT_B0(yeark,"0116", "0250")+ IOT_B0(yeark,"0116", "0251")+ IOT_B0(yeark,"0116", "0252") ) ;);
         loop(yeark$(not t(yeark) and (IOT_B0(yeark+1,"0116", "0197"))), Emit_Prcs(yeark,"HFCs","0197") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0(yeark+1,"0116", "0197") / ( IOT_B0(yeark+1,"0116", "0197") + IOT_B0(yeark+1,"0116", "0200") + IOT_B0(yeark+1,"0116", "0249") + IOT_B0(yeark+1,"0116", "0250")+ IOT_B0(yeark+1,"0116", "0251")+ IOT_B0(yeark+1,"0116", "0252") ) ;);
         loop(yeark$(not t(yeark) and not IOT_B0(yeark+1,"0116", "0197")), Emit_Prcs(yeark,"HFCs","0197") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0("2003","0116", "0197") / ( IOT_B0("2003","0116", "0197") + IOT_B0("2003","0116", "0200") + IOT_B0("2003","0116", "0249") + IOT_B0("2003","0116", "0250")+ IOT_B0("2003","0116", "0251")+ IOT_B0("2003","0116", "0252") ) ;););

**할로카본 소비에 따른 기타일반목적용기계 HFCs 배출량 (ton CO2단위로 환산) (2.F.1-2.F.6)  "0229"
if(not Prcs_ratio,
         Emit_Prcs(t,"HFCs","0200")$(not told(t)) = ((Data_HFC152a(t) * 140 / 1000) + ( Data_HFC123a(t) * 1300 / 1000 )) *
         IOT_B0(t,"0116", "0200") / ( IOT_B0(t,"0116", "0197") + IOT_B0(t,"0116", "0200") + IOT_B0(t,"0116", "0249") + IOT_B0(t,"0116", "0250")+ IOT_B0(t,"0116", "0251")+ IOT_B0(t,"0116", "0252") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"HFCs","0200") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0(yeark,"0116", "0200") / ( IOT_B0(yeark,"0116", "0197") + IOT_B0(yeark,"0116", "0200") + IOT_B0(yeark,"0116", "0249") + IOT_B0(yeark,"0116", "0250")+ IOT_B0(yeark,"0116", "0251")+ IOT_B0(yeark,"0116", "0252") ) ;);
         loop(yeark$(not t(yeark) and (IOT_B0(yeark+1,"0116", "0197"))), Emit_Prcs(yeark,"HFCs","0200") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0(yeark+1,"0116", "0200") / ( IOT_B0(yeark+1,"0116", "0197") + IOT_B0(yeark+1,"0116", "0200") + IOT_B0(yeark+1,"0116", "0249") + IOT_B0(yeark+1,"0116", "0250")+ IOT_B0(yeark+1,"0116", "0251")+ IOT_B0(yeark+1,"0116", "0252") ) ;);
         loop(yeark$(not t(yeark) and not IOT_B0(yeark+1,"0116", "0197")), Emit_Prcs(yeark,"HFCs","0200") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0("2003","0116", "0200") / ( IOT_B0("2003","0116", "0197") + IOT_B0("2003","0116", "0200") + IOT_B0("2003","0116", "0249") + IOT_B0("2003","0116", "0250")+ IOT_B0("2003","0116", "0251")+ IOT_B0("2003","0116", "0252") ) ;););

**할로카본 소비에 따른 승용차 HFCs 배출량 (ton CO2단위로 환산) (2.F.1-2.F.6)      "0274"
if(not Prcs_ratio,
          Emit_Prcs(t,"HFCs","0249")$(not told(t)) = ((Data_HFC152a(t) * 140 / 1000) + ( Data_HFC123a(t) * 1300 / 1000 )) *
         IOT_B0(t,"0116", "0249") / ( IOT_B0(t,"0116", "0200") + IOT_B0(t,"0116", "0197") + IOT_B0(t,"0116", "0249") + IOT_B0(t,"0116", "0250")+ IOT_B0(t,"0116", "0251")+ IOT_B0(t,"0116", "0252") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"HFCs","0249") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0(yeark,"0116", "0249") / ( IOT_B0(yeark,"0116", "0197") + IOT_B0(yeark,"0116", "0200") + IOT_B0(yeark,"0116", "0249") + IOT_B0(yeark,"0116", "0250")+ IOT_B0(yeark,"0116", "0251")+ IOT_B0(yeark,"0116", "0252") ) ;);
         loop(yeark$(not t(yeark) and (IOT_B0(yeark+1,"0116", "0197"))), Emit_Prcs(yeark,"HFCs","0249") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0(yeark+1,"0116", "0249") / ( IOT_B0(yeark+1,"0116", "0197") + IOT_B0(yeark+1,"0116", "0200") + IOT_B0(yeark+1,"0116", "0249") + IOT_B0(yeark+1,"0116", "0250")+ IOT_B0(yeark+1,"0116", "0251")+ IOT_B0(yeark+1,"0116", "0252") ) ;);
         loop(yeark$(not t(yeark) and not IOT_B0(yeark+1,"0116", "0197")), Emit_Prcs(yeark,"HFCs","0249") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0("2003","0116", "0249") / ( IOT_B0("2003","0116", "0197") + IOT_B0("2003","0116", "0200") + IOT_B0("2003","0116", "0249") + IOT_B0("2003","0116", "0250")+ IOT_B0("2003","0116", "0251")+ IOT_B0("2003","0116", "0252") ) ;););

**할로카본 소비에 따른 승합차 HFCs 배출량  (ton CO2단위로 환산) (2.F.1-2.F.6)      "0275"
if(not Prcs_ratio,
         Emit_Prcs(t,"HFCs","0250")$(not told(t)) = ((Data_HFC152a(t) * 140 / 1000) + ( Data_HFC123a(t) * 1300 / 1000 )) *
         IOT_B0(t,"0116", "0250") / ( IOT_B0(t,"0116", "0200") + IOT_B0(t,"0116", "0197") + IOT_B0(t,"0116", "0249") + IOT_B0(t,"0116", "0250")+ IOT_B0(t,"0116", "0251")+ IOT_B0(t,"0116", "0252") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"HFCs","0250") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0(yeark,"0116", "0250") / ( IOT_B0(yeark,"0116", "0197") + IOT_B0(yeark,"0116", "0200") + IOT_B0(yeark,"0116", "0249") + IOT_B0(yeark,"0116", "0250")+ IOT_B0(yeark,"0116", "0251")+ IOT_B0(yeark,"0116", "0252") ) ;);
         loop(yeark$(not t(yeark) and (IOT_B0(yeark+1,"0116", "0197"))), Emit_Prcs(yeark,"HFCs","0250") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0(yeark+1,"0116", "0250") / ( IOT_B0(yeark+1,"0116", "0197") + IOT_B0(yeark+1,"0116", "0200") + IOT_B0(yeark+1,"0116", "0249") + IOT_B0(yeark+1,"0116", "0250")+ IOT_B0(yeark+1,"0116", "0251")+ IOT_B0(yeark+1,"0116", "0252") ) ;);
         loop(yeark$(not t(yeark) and not IOT_B0(yeark+1,"0116", "0197")), Emit_Prcs(yeark,"HFCs","0250") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0("2003","0116", "0250") / ( IOT_B0("2003","0116", "0197") + IOT_B0("2003","0116", "0200") + IOT_B0("2003","0116", "0249") + IOT_B0("2003","0116", "0250")+ IOT_B0("2003","0116", "0251")+ IOT_B0("2003","0116", "0252") ) ;););

**할로카본 소비에 따른 화물자동차 HFCs 배출량  (ton CO2단위로 환산) (2.F.1-2.F.6)   "0276"
if(not Prcs_ratio,
         Emit_Prcs(t,"HFCs","0251")$(not told(t)) = ((Data_HFC152a(t) * 140 / 1000) + ( Data_HFC123a(t) * 1300 / 1000 )) *
         IOT_B0(t,"0116", "0251") / ( IOT_B0(t,"0116", "0200") + IOT_B0(t,"0116", "0197") + IOT_B0(t,"0116", "0249") + IOT_B0(t,"0116", "0250")+ IOT_B0(t,"0116", "0251")+ IOT_B0(t,"0116", "0252") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"HFCs","0251") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0(yeark,"0116", "0251") / ( IOT_B0(yeark,"0116", "0197") + IOT_B0(yeark,"0116", "0200") + IOT_B0(yeark,"0116", "0249") + IOT_B0(yeark,"0116", "0250")+ IOT_B0(yeark,"0116", "0251")+ IOT_B0(yeark,"0116", "0252") ) ;);
         loop(yeark$(not t(yeark) and (IOT_B0(yeark+1,"0116", "0197"))), Emit_Prcs(yeark,"HFCs","0251") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0(yeark+1,"0116", "0251") / ( IOT_B0(yeark+1,"0116", "0197") + IOT_B0(yeark+1,"0116", "0200") + IOT_B0(yeark+1,"0116", "0249") + IOT_B0(yeark+1,"0116", "0250")+ IOT_B0(yeark+1,"0116", "0251")+ IOT_B0(yeark+1,"0116", "0252") ) ;);
         loop(yeark$(not t(yeark) and not IOT_B0(yeark+1,"0116", "0197")), Emit_Prcs(yeark,"HFCs","0251") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0("2003","0116", "0251") / ( IOT_B0("2003","0116", "0197") + IOT_B0("2003","0116", "0200") + IOT_B0("2003","0116", "0249") + IOT_B0("2003","0116", "0250")+ IOT_B0("2003","0116", "0251")+ IOT_B0("2003","0116", "0252") ) ;););

**할로카본 소비에 따른 특장차 HFCs 배출량  (ton CO2단위로 환산) (2.F.1-2.F.6)   "0277"
if(not Prcs_ratio,
         Emit_Prcs(t,"HFCs","0252")$(not told(t)) = ((Data_HFC152a(t) * 140 / 1000) + ( Data_HFC123a(t) * 1300 / 1000 )) *
         IOT_B0(t,"0116", "0252") / ( IOT_B0(t,"0116", "0200") + IOT_B0(t,"0116", "0197") + IOT_B0(t,"0116", "0249") + IOT_B0(t,"0116", "0250")+ IOT_B0(t,"0116", "0251")+ IOT_B0(t,"0116", "0252") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"HFCs","0252") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0(yeark,"0116", "0252") / ( IOT_B0(yeark,"0116", "0197") + IOT_B0(yeark,"0116", "0200") + IOT_B0(yeark,"0116", "0249") + IOT_B0(yeark,"0116", "0250")+ IOT_B0(yeark,"0116", "0251")+ IOT_B0(yeark,"0116", "0252") ) ;);
         loop(yeark$(not t(yeark) and (IOT_B0(yeark+1,"0116", "0197"))), Emit_Prcs(yeark,"HFCs","0252") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0(yeark+1,"0116", "0252") / ( IOT_B0(yeark+1,"0116", "0197") + IOT_B0(yeark+1,"0116", "0200") + IOT_B0(yeark+1,"0116", "0249") + IOT_B0(yeark+1,"0116", "0250")+ IOT_B0(yeark+1,"0116", "0251")+ IOT_B0(yeark+1,"0116", "0252") ) ;);
         loop(yeark$(not t(yeark) and not IOT_B0(yeark+1,"0116", "0197")), Emit_Prcs(yeark,"HFCs","0252") = ((Data_HFC152a(yeark) * 140 / 1000) + ( Data_HFC123a(yeark) * 1300 / 1000 )) *
         IOT_B0("2003","0116", "0252") / ( IOT_B0("2003","0116", "0197") + IOT_B0("2003","0116", "0200") + IOT_B0("2003","0116", "0249") + IOT_B0("2003","0116", "0250")+ IOT_B0("2003","0116", "0251")+ IOT_B0("2003","0116", "0252") ) ;););

**반도체  "0250="Semiconductor devices"/0251="Integrated circuits"
** In 2010,
*"0250="Semiconductor devices" => 0224
*"0251="Integrated circuits"=> 0225
set gases /CF4, C2F6, C3F8, C4F8, CHF3, CH2F2, C2HF5, SF6, CO2, CH4,N2O, Remains/;
set PFCs(gases) /CF4, C2F6, C3F8, C4F8/
set HFCs(gases) /CHF3, CH2F2, C2HF5/;

set gvalue /R1, R2,  R3,  R_CF4, R_C2F6, R_CHF3, R4,GWP /;

Parameters DATA_GASES1(gases,yeark), DATA_GASES2(gases,gvalue) ;
**READ** 반도체 가스 사용량 (Ton)
$LIBINCLUDE XLIMPORT DATA_GASES1 emissions_estimation\GIR_Emissions.xlsx Consumption_of_halocarbons(2.F)!c20..AZ30     ;
**READ** 계산에 필요한 수치 및 GWP
$LIBINCLUDE XLIMPORT DATA_GASES2 emissions_estimation\GIR_Emissions.xlsx Consumption_of_halocarbons(2.F)!a34..H44     ;

**할로카본 소비에 따른 반도체(개별소자) 온실가스 배출량  (ton CO2단위로 환산) (2.F.7)
*PFC HFC SF6: Emission =USAGE*(1-R1)*R2*(1-R3 or 1-R4)*GWP. R1= What is left on tank, R2= Residual after use , R3=What is cleaned automatically, R4=removal of byproduct
*CO2 CH4 N20: Emission =USAGE*(1-R1)*(1-R2)*(1-R3)
if(not Prcs_ratio,
Emit_Prcs(t,"PFCs","0224")$(SUM(PFCs, (DATA_GASES1(PFCS,t))) and not told(t)) = ( SUM(PFCs, (DATA_GASES1(PFCS,t) * (1- DATA_GASES2(PFCS,"R1")) * DATA_GASES2(PFCS,"R2") * (1-DATA_GASES2(PFCS,"R3")) * DATA_GASES2(PFCS,"GWP")) )
         + ( DATA_GASES1("C4F8",t) * (1- DATA_GASES2("C4F8","R1")) * DATA_GASES2("C4F8","R_C2F6") * (1-DATA_GASES2("C4F8","R4")) * DATA_GASES2("C2F6","GWP") )
         + (SUM(PFCS, (DATA_GASES1(PFCS,t) * (1- DATA_GASES2(PFCS,"R1")) * DATA_GASES2(PFCS,"R_CF4") * (1-DATA_GASES2(PFCS,"R4"))) ) + SUM(HFCS, (DATA_GASES1(HFCS,t) * (1- DATA_GASES2(HFCS,"R1")) * DATA_GASES2(HFCS,"R_CF4") * (1-DATA_GASES2(HFCS,"R4"))) ) -  (DATA_GASES1("CF4",t) * (1- DATA_GASES2("CF4","R1")) * DATA_GASES2("CF4","R_CF4") * (1-DATA_GASES2("CF4","R4")) )) * DATA_GASES2("CF4","GWP") ) * xp_b0(t,"0224") / ( xp_b0(t,"0224") + xp_b0(t,"0225") ) ;

Emit_Prcs(t,"HFCs","0224")$(SUM(HFCS, (DATA_GASES1(HFCS,t))) and not told(t)) = SUM(HFCS, (DATA_GASES1(HFCS,t) * (1- DATA_GASES2(HFCS,"R1")) * DATA_GASES2(HFCS,"R2") * (1-DATA_GASES2(HFCS,"R3")) * DATA_GASES2(HFCS,"GWP")) ) * xp_b0(t,"0224") / ( xp_b0(t,"0224") + xp_b0(t,"0225") )  ;

Emit_Prcs(t,"SF6","0224")$(DATA_GASES1("SF6",t) and not told(t)) = DATA_GASES1("SF6",t) * (1- DATA_GASES2("SF6","R1")) * DATA_GASES2("SF6","R2") * (1-DATA_GASES2("SF6","R3")) * DATA_GASES2("SF6","GWP") * xp_b0(t,"0224") / ( xp_b0(t,"0224") + xp_b0(t,"0225") ) ;
Emit_Prcs(t,"CO2","0224")$(DATA_GASES1("CO2",t) and not told(t))= DATA_GASES1("CO2",t) * (1- DATA_GASES2("CO2","R1")) * (1-DATA_GASES2("CO2","R2")) * (1-DATA_GASES2("CO2","R3")) * DATA_GASES2("CO2","GWP") * xp_b0(t,"0224") / ( xp_b0(t,"0224") + xp_b0(t,"0225") )  ;
Emit_Prcs(t,"CH4","0224")$(DATA_GASES1("CH4",t) and not told(t))= DATA_GASES1("CH4",t) * (1- DATA_GASES2("CH4","R1")) * (1-DATA_GASES2("CH4","R2")) * (1-DATA_GASES2("CH4","R3")) * DATA_GASES2("CH4","GWP") * xp_b0(t,"0224") / ( xp_b0(t,"0224") + xp_b0(t,"0225") )  ;
Emit_Prcs(t,"N2O","0224")$(DATA_GASES1("N2O",t) and not told(t))= DATA_GASES1("N2O",t) * (1- DATA_GASES2("N2O","R1")) * (1-DATA_GASES2("N2O","R2")) * (1-DATA_GASES2("N2O","R3")) * DATA_GASES2("N2O","GWP") * xp_b0(t,"0224") / ( xp_b0(t,"0224") + xp_b0(t,"0225") )  ;

);

if(Prcs_ratio,
loop(yeark$t(yeark),
Emit_Prcs(yeark,"PFCs","0224")$SUM(PFCs, (DATA_GASES1(PFCS,yeark))) = ( SUM(PFCs, (DATA_GASES1(PFCS,yeark) * (1- DATA_GASES2(PFCS,"R1")) * DATA_GASES2(PFCS,"R2") * (1-DATA_GASES2(PFCS,"R3")) * DATA_GASES2(PFCS,"GWP")) )
         + ( DATA_GASES1("C4F8",yeark) * (1- DATA_GASES2("C4F8","R1")) * DATA_GASES2("C4F8","R_C2F6") * (1-DATA_GASES2("C4F8","R4")) * DATA_GASES2("C2F6","GWP") )
         + (SUM(PFCS, (DATA_GASES1(PFCS,yeark) * (1- DATA_GASES2(PFCS,"R1")) * DATA_GASES2(PFCS,"R_CF4") * (1-DATA_GASES2(PFCS,"R4"))) ) + SUM(HFCS, (DATA_GASES1(HFCS,yeark) * (1- DATA_GASES2(HFCS,"R1")) * DATA_GASES2(HFCS,"R_CF4") * (1-DATA_GASES2(HFCS,"R4"))) ) -  (DATA_GASES1("CF4",yeark) * (1- DATA_GASES2("CF4","R1")) * DATA_GASES2("CF4","R_CF4") * (1-DATA_GASES2("CF4","R4")) )) * DATA_GASES2("CF4","GWP") ) * xp_b0(yeark,"0224") / ( xp_b0(yeark,"0224") + xp_b0(yeark,"0225") ) ;

Emit_Prcs(yeark,"HFCs","0224")$SUM(HFCS, (DATA_GASES1(HFCS,yeark))) = SUM(HFCS, (DATA_GASES1(HFCS,yeark) * (1- DATA_GASES2(HFCS,"R1")) * DATA_GASES2(HFCS,"R2") * (1-DATA_GASES2(HFCS,"R3")) * DATA_GASES2(HFCS,"GWP")) ) * xp_b0(yeark,"0224") / ( xp_b0(yeark,"0224") + xp_b0(yeark,"0225") )  ;

Emit_Prcs(yeark,"SF6","0224")$DATA_GASES1("SF6",yeark) = DATA_GASES1("SF6",yeark) * (1- DATA_GASES2("SF6","R1")) * DATA_GASES2("SF6","R2") * (1-DATA_GASES2("SF6","R3")) * DATA_GASES2("SF6","GWP") * xp_b0(yeark,"0224") / ( xp_b0(yeark,"0224") + xp_b0(yeark,"0225") ) ;
Emit_Prcs(yeark,"CO2","0224")$DATA_GASES1("CO2",yeark) = DATA_GASES1("CO2",yeark) * (1- DATA_GASES2("CO2","R1")) * (1-DATA_GASES2("CO2","R2")) * (1-DATA_GASES2("CO2","R3")) * DATA_GASES2("CO2","GWP") * xp_b0(yeark,"0224") / ( xp_b0(yeark,"0224") + xp_b0(yeark,"0225") )  ;
Emit_Prcs(yeark,"CH4","0224")$DATA_GASES1("CH4",yeark) = DATA_GASES1("CH4",yeark) * (1- DATA_GASES2("CH4","R1")) * (1-DATA_GASES2("CH4","R2")) * (1-DATA_GASES2("CH4","R3")) * DATA_GASES2("CH4","GWP") * xp_b0(yeark,"0224") / ( xp_b0(yeark,"0224") + xp_b0(yeark,"0225") )  ;
Emit_Prcs(yeark,"N2O","0224")$DATA_GASES1("N2O",yeark) = DATA_GASES1("N2O",yeark) * (1- DATA_GASES2("N2O","R1")) * (1-DATA_GASES2("N2O","R2")) * (1-DATA_GASES2("N2O","R3")) * DATA_GASES2("N2O","GWP") * xp_b0(yeark,"0224") / ( xp_b0(yeark,"0224") + xp_b0(yeark,"0225") )  ;
);
loop(yeark$(not t(yeark) and (xp_B0(yeark+1,"0224"))),
Emit_Prcs(yeark,"PFCs","0224")$SUM(PFCs, (DATA_GASES1(PFCS,yeark))) = ( SUM(PFCs, (DATA_GASES1(PFCS,yeark) * (1- DATA_GASES2(PFCS,"R1")) * DATA_GASES2(PFCS,"R2") * (1-DATA_GASES2(PFCS,"R3")) * DATA_GASES2(PFCS,"GWP")) )
         + ( DATA_GASES1("C4F8",yeark) * (1- DATA_GASES2("C4F8","R1")) * DATA_GASES2("C4F8","R_C2F6") * (1-DATA_GASES2("C4F8","R4")) * DATA_GASES2("C2F6","GWP") )
         + (SUM(PFCS, (DATA_GASES1(PFCS,yeark) * (1- DATA_GASES2(PFCS,"R1")) * DATA_GASES2(PFCS,"R_CF4") * (1-DATA_GASES2(PFCS,"R4"))) ) + SUM(HFCS, (DATA_GASES1(HFCS,yeark) * (1- DATA_GASES2(HFCS,"R1")) * DATA_GASES2(HFCS,"R_CF4") * (1-DATA_GASES2(HFCS,"R4"))) ) -  (DATA_GASES1("CF4",yeark) * (1- DATA_GASES2("CF4","R1")) * DATA_GASES2("CF4","R_CF4") * (1-DATA_GASES2("CF4","R4")) )) * DATA_GASES2("CF4","GWP") ) * xp_b0(yeark+1,"0224") / ( xp_b0(yeark+1,"0224") + xp_b0(yeark+1,"0225") ) ;

Emit_Prcs(yeark,"HFCs","0224")$SUM(HFCS, (DATA_GASES1(HFCS,yeark))) = SUM(HFCS, (DATA_GASES1(HFCS,yeark) * (1- DATA_GASES2(HFCS,"R1")) * DATA_GASES2(HFCS,"R2") * (1-DATA_GASES2(HFCS,"R3")) * DATA_GASES2(HFCS,"GWP")) ) * xp_b0(yeark+1,"0224") / ( xp_b0(yeark+1,"0224") + xp_b0(yeark+1,"0225") )  ;

Emit_Prcs(yeark,"SF6","0224")$DATA_GASES1("SF6",yeark) = DATA_GASES1("SF6",yeark) * (1- DATA_GASES2("SF6","R1")) * DATA_GASES2("SF6","R2") * (1-DATA_GASES2("SF6","R3")) * DATA_GASES2("SF6","GWP") * xp_b0(yeark+1,"0224") / ( xp_b0(yeark+1,"0224") + xp_b0(yeark+1,"0225") ) ;
Emit_Prcs(yeark,"CO2","0224")$DATA_GASES1("CO2",yeark) = DATA_GASES1("CO2",yeark) * (1- DATA_GASES2("CO2","R1")) * (1-DATA_GASES2("CO2","R2")) * (1-DATA_GASES2("CO2","R3")) * DATA_GASES2("CO2","GWP") * xp_b0(yeark+1,"0224") / ( xp_b0(yeark+1,"0224") + xp_b0(yeark+1,"0225") )  ;
Emit_Prcs(yeark,"CH4","0224")$DATA_GASES1("CH4",yeark) = DATA_GASES1("CH4",yeark) * (1- DATA_GASES2("CH4","R1")) * (1-DATA_GASES2("CH4","R2")) * (1-DATA_GASES2("CH4","R3")) * DATA_GASES2("CH4","GWP") * xp_b0(yeark+1,"0224") / ( xp_b0(yeark+1,"0224") + xp_b0(yeark+1,"0225") )  ;
Emit_Prcs(yeark,"N2O","0224")$DATA_GASES1("N2O",yeark) = DATA_GASES1("N2O",yeark) * (1- DATA_GASES2("N2O","R1")) * (1-DATA_GASES2("N2O","R2")) * (1-DATA_GASES2("N2O","R3")) * DATA_GASES2("N2O","GWP") * xp_b0(yeark+1,"0224") / ( xp_b0(yeark+1,"0224") + xp_b0(yeark+1,"0225") )  ;
);
loop(yeark$(not t(yeark) and not xp_B0(yeark+1,"0224")),
Emit_Prcs(yeark,"PFCs","0224")$SUM(PFCs, (DATA_GASES1(PFCS,yeark))) = ( SUM(PFCs, (DATA_GASES1(PFCS,yeark) * (1- DATA_GASES2(PFCS,"R1")) * DATA_GASES2(PFCS,"R2") * (1-DATA_GASES2(PFCS,"R3")) * DATA_GASES2(PFCS,"GWP")) )
         + ( DATA_GASES1("C4F8",yeark) * (1- DATA_GASES2("C4F8","R1")) * DATA_GASES2("C4F8","R_C2F6") * (1-DATA_GASES2("C4F8","R4")) * DATA_GASES2("C2F6","GWP") )
         + (SUM(PFCS, (DATA_GASES1(PFCS,yeark) * (1- DATA_GASES2(PFCS,"R1")) * DATA_GASES2(PFCS,"R_CF4") * (1-DATA_GASES2(PFCS,"R4"))) ) + SUM(HFCS, (DATA_GASES1(HFCS,yeark) * (1- DATA_GASES2(HFCS,"R1")) * DATA_GASES2(HFCS,"R_CF4") * (1-DATA_GASES2(HFCS,"R4"))) ) -  (DATA_GASES1("CF4",yeark) * (1- DATA_GASES2("CF4","R1")) * DATA_GASES2("CF4","R_CF4") * (1-DATA_GASES2("CF4","R4")) )) * DATA_GASES2("CF4","GWP") ) * xp_b0("2003","0224") / ( xp_b0("2003","0224") + xp_b0("2003","0225") ) ;

Emit_Prcs(yeark,"HFCs","0224")$SUM(HFCS, (DATA_GASES1(HFCS,yeark))) = SUM(HFCS, (DATA_GASES1(HFCS,yeark) * (1- DATA_GASES2(HFCS,"R1")) * DATA_GASES2(HFCS,"R2") * (1-DATA_GASES2(HFCS,"R3")) * DATA_GASES2(HFCS,"GWP")) ) * xp_b0("2003","0224") / ( xp_b0("2003","0224") + xp_b0("2003","0230") )  ;

Emit_Prcs(yeark,"SF6","0224")$DATA_GASES1("SF6",yeark) = DATA_GASES1("SF6",yeark) * (1- DATA_GASES2("SF6","R1")) * DATA_GASES2("SF6","R2") * (1-DATA_GASES2("SF6","R3")) * DATA_GASES2("SF6","GWP") * xp_b0("2003","0224") / ( xp_b0("2003","0224") + xp_b0("2003","0225") ) ;
Emit_Prcs(yeark,"CO2","0224")$DATA_GASES1("CO2",yeark) = DATA_GASES1("CO2",yeark) * (1- DATA_GASES2("CO2","R1")) * (1-DATA_GASES2("CO2","R2")) * (1-DATA_GASES2("CO2","R3")) * DATA_GASES2("CO2","GWP") * xp_b0("2003","0224") / ( xp_b0("2003","0224") + xp_b0("2003","0225") )  ;
Emit_Prcs(yeark,"CH4","0224")$DATA_GASES1("CH4",yeark) = DATA_GASES1("CH4",yeark) * (1- DATA_GASES2("CH4","R1")) * (1-DATA_GASES2("CH4","R2")) * (1-DATA_GASES2("CH4","R3")) * DATA_GASES2("CH4","GWP") * xp_b0("2003","0224") / ( xp_b0("2003","0224") + xp_b0("2003","0225") )  ;
Emit_Prcs(yeark,"N2O","0224")$DATA_GASES1("N2O",yeark) = DATA_GASES1("N2O",yeark) * (1- DATA_GASES2("N2O","R1")) * (1-DATA_GASES2("N2O","R2")) * (1-DATA_GASES2("N2O","R3")) * DATA_GASES2("N2O","GWP") * xp_b0("2003","0224") / ( xp_b0("2003","0224") + xp_b0("2003","0225") )  ;
);
);

**할로카본 소비에 따른 반도체(집적회로) 온실가스 배출량  (ton CO2단위로 환산) (2.F.7)
if(not Prcs_ratio,
Emit_Prcs(t,"PFCs","0225")$(SUM(PFCs, (DATA_GASES1(PFCS,t))) and not told(t)) = ( SUM(PFCs, (DATA_GASES1(PFCS,t) * (1- DATA_GASES2(PFCS,"R1")) * DATA_GASES2(PFCS,"R2") * (1-DATA_GASES2(PFCS,"R3")) * DATA_GASES2(PFCS,"GWP")) )
         + ( DATA_GASES1("C4F8",t) * (1- DATA_GASES2("C4F8","R1")) * DATA_GASES2("C4F8","R_C2F6") * (1-DATA_GASES2("C4F8","R4")) * DATA_GASES2("C2F6","GWP") )
         + (SUM(PFCS, (DATA_GASES1(PFCS,t) * (1- DATA_GASES2(PFCS,"R1")) * DATA_GASES2(PFCS,"R_CF4") * (1-DATA_GASES2(PFCS,"R4"))) ) + SUM(HFCS, (DATA_GASES1(HFCS,t) * (1- DATA_GASES2(HFCS,"R1")) * DATA_GASES2(HFCS,"R_CF4") * (1-DATA_GASES2(HFCS,"R4"))) ) -  (DATA_GASES1("CF4",t) * (1- DATA_GASES2("CF4","R1")) * DATA_GASES2("CF4","R_CF4") * (1-DATA_GASES2("CF4","R4")) )) * DATA_GASES2("CF4","GWP") ) * xp_b0(t,"0225") / ( xp_b0(t,"0224") + xp_b0(t,"0225") ) ;

Emit_Prcs(t,"HFCs","0225")$(SUM(HFCS, (DATA_GASES1(HFCS,t))) and not told(t)) = SUM(HFCS, (DATA_GASES1(HFCS,t) * (1- DATA_GASES2(HFCS,"R1")) * DATA_GASES2(HFCS,"R2") * (1-DATA_GASES2(HFCS,"R3")) * DATA_GASES2(HFCS,"GWP")) ) * xp_b0(t,"0225") / ( xp_b0(t,"0224") + xp_b0(t,"0225") )  ;

Emit_Prcs(t,"SF6","0225")$(DATA_GASES1("SF6",t) and not told(t)) = DATA_GASES1("SF6",t) * (1- DATA_GASES2("SF6","R1")) * DATA_GASES2("SF6","R2") * (1-DATA_GASES2("SF6","R3")) * DATA_GASES2("SF6","GWP") * xp_b0(t,"0225") / ( xp_b0(t,"0224") + xp_b0(t,"0225") )  ;
Emit_Prcs(t,"CO2","0225")$(DATA_GASES1("CO2",t) and not told(t)) = DATA_GASES1("CO2",t) * (1- DATA_GASES2("CO2","R1")) * (1-DATA_GASES2("CO2","R2")) * (1-DATA_GASES2("CO2","R3")) * DATA_GASES2("CO2","GWP") * xp_b0(t,"0225") / ( xp_b0(t,"0224") + xp_b0(t,"0225") )  ;
Emit_Prcs(t,"CH4","0225")$(DATA_GASES1("CH4",t) and not told(t)) = DATA_GASES1("CH4",t) * (1- DATA_GASES2("CH4","R1")) * (1-DATA_GASES2("CH4","R2")) * (1-DATA_GASES2("CH4","R3")) * DATA_GASES2("CH4","GWP") * xp_b0(t,"0225") / ( xp_b0(t,"0224") + xp_b0(t,"0225") )  ;
Emit_Prcs(t,"N2O","0225")$(DATA_GASES1("N2O",t) and not told(t)) = DATA_GASES1("N2O",t) * (1- DATA_GASES2("N2O","R1")) * (1-DATA_GASES2("N2O","R2")) * (1-DATA_GASES2("N2O","R3")) * DATA_GASES2("N2O","GWP") * xp_b0(t,"0225") / ( xp_b0(t,"0224") + xp_b0(t,"0225") )  ;
);

if(Prcs_ratio,
loop(yeark$t(yeark),
Emit_Prcs(yeark,"PFCs","0225")$SUM(PFCs, (DATA_GASES1(PFCS,yeark))) = ( SUM(PFCs, (DATA_GASES1(PFCS,yeark) * (1- DATA_GASES2(PFCS,"R1")) * DATA_GASES2(PFCS,"R2") * (1-DATA_GASES2(PFCS,"R3")) * DATA_GASES2(PFCS,"GWP")) )
         + ( DATA_GASES1("C4F8",yeark) * (1- DATA_GASES2("C4F8","R1")) * DATA_GASES2("C4F8","R_C2F6") * (1-DATA_GASES2("C4F8","R4")) * DATA_GASES2("C2F6","GWP") )
         + (SUM(PFCS, (DATA_GASES1(PFCS,yeark) * (1- DATA_GASES2(PFCS,"R1")) * DATA_GASES2(PFCS,"R_CF4") * (1-DATA_GASES2(PFCS,"R4"))) ) + SUM(HFCS, (DATA_GASES1(HFCS,yeark) * (1- DATA_GASES2(HFCS,"R1")) * DATA_GASES2(HFCS,"R_CF4") * (1-DATA_GASES2(HFCS,"R4"))) ) -  (DATA_GASES1("CF4",yeark) * (1- DATA_GASES2("CF4","R1")) * DATA_GASES2("CF4","R_CF4") * (1-DATA_GASES2("CF4","R4")) )) * DATA_GASES2("CF4","GWP") ) * xp_b0(yeark,"0225") / ( xp_b0(yeark,"0224") + xp_b0(yeark,"0225") ) ;

Emit_Prcs(yeark,"HFCs","0225")$SUM(HFCS, (DATA_GASES1(HFCS,yeark))) = SUM(HFCS, (DATA_GASES1(HFCS,yeark) * (1- DATA_GASES2(HFCS,"R1")) * DATA_GASES2(HFCS,"R2") * (1-DATA_GASES2(HFCS,"R3")) * DATA_GASES2(HFCS,"GWP")) ) * xp_b0(yeark,"0225") / ( xp_b0(yeark,"0224") + xp_b0(yeark,"0225") )  ;

Emit_Prcs(yeark,"SF6","0225")$DATA_GASES1("SF6",yeark) = DATA_GASES1("SF6",yeark) * (1- DATA_GASES2("SF6","R1")) * DATA_GASES2("SF6","R2") * (1-DATA_GASES2("SF6","R3")) * DATA_GASES2("SF6","GWP") * xp_b0(yeark,"0225") / ( xp_b0(yeark,"0224") + xp_b0(yeark,"0225") )  ;
Emit_Prcs(yeark,"CO2","0225")$DATA_GASES1("CO2",yeark) = DATA_GASES1("CO2",yeark) * (1- DATA_GASES2("CO2","R1")) * (1-DATA_GASES2("CO2","R2")) * (1-DATA_GASES2("CO2","R3")) * DATA_GASES2("CO2","GWP") * xp_b0(yeark,"0225") / ( xp_b0(yeark,"0224") + xp_b0(yeark,"0225") )  ;
Emit_Prcs(yeark,"CH4","0225")$DATA_GASES1("CH4",yeark) = DATA_GASES1("CH4",yeark) * (1- DATA_GASES2("CH4","R1")) * (1-DATA_GASES2("CH4","R2")) * (1-DATA_GASES2("CH4","R3")) * DATA_GASES2("CH4","GWP") * xp_b0(yeark,"0225") / ( xp_b0(yeark,"0224") + xp_b0(yeark,"0225") )  ;
Emit_Prcs(yeark,"N2O","0225")$DATA_GASES1("N2O",yeark) = DATA_GASES1("N2O",yeark) * (1- DATA_GASES2("N2O","R1")) * (1-DATA_GASES2("N2O","R2")) * (1-DATA_GASES2("N2O","R3")) * DATA_GASES2("N2O","GWP") * xp_b0(yeark,"0225") / ( xp_b0(yeark,"0224") + xp_b0(yeark,"0225") )  ;
);
loop(yeark$(not t(yeark) and (xp_B0(yeark+1,"0224"))),
Emit_Prcs(yeark,"PFCs","0225")$SUM(PFCs, (DATA_GASES1(PFCS,yeark))) = ( SUM(PFCs, (DATA_GASES1(PFCS,yeark) * (1- DATA_GASES2(PFCS,"R1")) * DATA_GASES2(PFCS,"R2") * (1-DATA_GASES2(PFCS,"R3")) * DATA_GASES2(PFCS,"GWP")) )
         + ( DATA_GASES1("C4F8",yeark) * (1- DATA_GASES2("C4F8","R1")) * DATA_GASES2("C4F8","R_C2F6") * (1-DATA_GASES2("C4F8","R4")) * DATA_GASES2("C2F6","GWP") )
         + (SUM(PFCS, (DATA_GASES1(PFCS,yeark) * (1- DATA_GASES2(PFCS,"R1")) * DATA_GASES2(PFCS,"R_CF4") * (1-DATA_GASES2(PFCS,"R4"))) ) + SUM(HFCS, (DATA_GASES1(HFCS,yeark) * (1- DATA_GASES2(HFCS,"R1")) * DATA_GASES2(HFCS,"R_CF4") * (1-DATA_GASES2(HFCS,"R4"))) ) -  (DATA_GASES1("CF4",yeark) * (1- DATA_GASES2("CF4","R1")) * DATA_GASES2("CF4","R_CF4") * (1-DATA_GASES2("CF4","R4")) )) * DATA_GASES2("CF4","GWP") ) * xp_b0(yeark+1,"0225") / ( xp_b0(yeark+1,"0224") + xp_b0(yeark+1,"0225") ) ;

Emit_Prcs(yeark,"HFCs","0225")$SUM(HFCS, (DATA_GASES1(HFCS,yeark))) = SUM(HFCS, (DATA_GASES1(HFCS,yeark) * (1- DATA_GASES2(HFCS,"R1")) * DATA_GASES2(HFCS,"R2") * (1-DATA_GASES2(HFCS,"R3")) * DATA_GASES2(HFCS,"GWP")) ) * xp_b0(yeark+1,"0225") / ( xp_b0(yeark+1,"0224") + xp_b0(yeark+1,"0225") )  ;

Emit_Prcs(yeark,"SF6","0225")$DATA_GASES1("SF6",yeark) = DATA_GASES1("SF6",yeark) * (1- DATA_GASES2("SF6","R1")) * DATA_GASES2("SF6","R2") * (1-DATA_GASES2("SF6","R3")) * DATA_GASES2("SF6","GWP") * xp_b0(yeark+1,"0225") / ( xp_b0(yeark+1,"0224") + xp_b0(yeark+1,"0225") )  ;
Emit_Prcs(yeark,"CO2","0225")$DATA_GASES1("CO2",yeark) = DATA_GASES1("CO2",yeark) * (1- DATA_GASES2("CO2","R1")) * (1-DATA_GASES2("CO2","R2")) * (1-DATA_GASES2("CO2","R3")) * DATA_GASES2("CO2","GWP") * xp_b0(yeark+1,"0225") / ( xp_b0(yeark+1,"0224") + xp_b0(yeark+1,"0225") )  ;
Emit_Prcs(yeark,"CH4","0225")$DATA_GASES1("CH4",yeark) = DATA_GASES1("CH4",yeark) * (1- DATA_GASES2("CH4","R1")) * (1-DATA_GASES2("CH4","R2")) * (1-DATA_GASES2("CH4","R3")) * DATA_GASES2("CH4","GWP") * xp_b0(yeark+1,"0225") / ( xp_b0(yeark+1,"0224") + xp_b0(yeark+1,"0225") )  ;
Emit_Prcs(yeark,"N2O","0225")$DATA_GASES1("N2O",yeark) = DATA_GASES1("N2O",yeark) * (1- DATA_GASES2("N2O","R1")) * (1-DATA_GASES2("N2O","R2")) * (1-DATA_GASES2("N2O","R3")) * DATA_GASES2("N2O","GWP") * xp_b0(yeark+1,"0225") / ( xp_b0(yeark+1,"0224") + xp_b0(yeark+1,"0225") )  ;
);
loop(yeark$(not t(yeark) and not xp_B0(yeark+1,"0224")),
Emit_Prcs(yeark,"PFCs","0225")$SUM(PFCs, (DATA_GASES1(PFCS,yeark))) = ( SUM(PFCs, (DATA_GASES1(PFCS,yeark) * (1- DATA_GASES2(PFCS,"R1")) * DATA_GASES2(PFCS,"R2") * (1-DATA_GASES2(PFCS,"R3")) * DATA_GASES2(PFCS,"GWP")) )
         + ( DATA_GASES1("C4F8",yeark) * (1- DATA_GASES2("C4F8","R1")) * DATA_GASES2("C4F8","R_C2F6") * (1-DATA_GASES2("C4F8","R4")) * DATA_GASES2("C2F6","GWP") )
         + (SUM(PFCS, (DATA_GASES1(PFCS,yeark) * (1- DATA_GASES2(PFCS,"R1")) * DATA_GASES2(PFCS,"R_CF4") * (1-DATA_GASES2(PFCS,"R4"))) ) + SUM(HFCS, (DATA_GASES1(HFCS,yeark) * (1- DATA_GASES2(HFCS,"R1")) * DATA_GASES2(HFCS,"R_CF4") * (1-DATA_GASES2(HFCS,"R4"))) ) -  (DATA_GASES1("CF4",yeark) * (1- DATA_GASES2("CF4","R1")) * DATA_GASES2("CF4","R_CF4") * (1-DATA_GASES2("CF4","R4")) )) * DATA_GASES2("CF4","GWP") ) * xp_b0("2003","0225") / ( xp_b0("2003","0224") + xp_b0("2003","0225") ) ;

Emit_Prcs(yeark,"HFCs","0225")$SUM(HFCS, (DATA_GASES1(HFCS,yeark))) = SUM(HFCS, (DATA_GASES1(HFCS,yeark) * (1- DATA_GASES2(HFCS,"R1")) * DATA_GASES2(HFCS,"R2") * (1-DATA_GASES2(HFCS,"R3")) * DATA_GASES2(HFCS,"GWP")) ) * xp_b0("2003","0225") / ( xp_b0("2003","0224") + xp_b0("2003","0225") )  ;

Emit_Prcs(yeark,"SF6","0225")$DATA_GASES1("SF6",yeark) = DATA_GASES1("SF6",yeark) * (1- DATA_GASES2("SF6","R1")) * DATA_GASES2("SF6","R2") * (1-DATA_GASES2("SF6","R3")) * DATA_GASES2("SF6","GWP") * xp_b0("2003","0225") / ( xp_b0("2003","0224") + xp_b0("2003","0225") )  ;
Emit_Prcs(yeark,"CO2","0225")$DATA_GASES1("CO2",yeark) = DATA_GASES1("CO2",yeark) * (1- DATA_GASES2("CO2","R1")) * (1-DATA_GASES2("CO2","R2")) * (1-DATA_GASES2("CO2","R3")) * DATA_GASES2("CO2","GWP") * xp_b0("2003","0225") / ( xp_b0("2003","0224") + xp_b0("2003","0225") )  ;
Emit_Prcs(yeark,"CH4","0225")$DATA_GASES1("CH4",yeark) = DATA_GASES1("CH4",yeark) * (1- DATA_GASES2("CH4","R1")) * (1-DATA_GASES2("CH4","R2")) * (1-DATA_GASES2("CH4","R3")) * DATA_GASES2("CH4","GWP") * xp_b0("2003","0225") / ( xp_b0("2003","0224") + xp_b0("2003","0225") )  ;
Emit_Prcs(yeark,"N2O","0225")$DATA_GASES1("N2O",yeark) = DATA_GASES1("N2O",yeark) * (1- DATA_GASES2("N2O","R1")) * (1-DATA_GASES2("N2O","R2")) * (1-DATA_GASES2("N2O","R3")) * DATA_GASES2("N2O","GWP") * xp_b0("2003","0225") / ( xp_b0("2003","0224") + xp_b0("2003","0225") )  ;
);
);




**액정
**same formula in Semicondoctor
** Industry 0249="Digital display"
** In 2010, 0249 => 0226
Parameters DATA_GASES3(gases,yeark), DATA_GASES4(gases,gvalue) ;
**READ** 액정 가스 사용량 (Ton)
$LIBINCLUDE XLIMPORT DATA_GASES3 emissions_estimation\GIR_Emissions.xlsx Consumption_of_halocarbons(2.F)!c67..AZ75     ;
**READ** 계산에 필요한 수치 및 GWP
$LIBINCLUDE XLIMPORT DATA_GASES4 emissions_estimation\GIR_Emissions.xlsx Consumption_of_halocarbons(2.F)!a78..I85     ;

**할로카본 소비에 따른 액정(디지털표시장치) 온실가스 배출량  (ton CO2단위로 환산) (2.F.7)
Emit_Prcs(yeark,"PFCs","0226") = SUM(PFCs, (DATA_GASES3(PFCS,yeark) * (1- DATA_GASES4(PFCS,"R1")) * DATA_GASES4(PFCS,"R2") * (1-DATA_GASES4(PFCS,"R3")) * DATA_GASES4(PFCS,"GWP")) )
         + ((( DATA_GASES3("C4F8",yeark) * (1- DATA_GASES4("C4F8","R1")) * DATA_GASES4("C4F8","R_CF4") * (1-DATA_GASES4("C4F8","R_CHF3"))) + ( DATA_GASES3("CHF3",yeark) * (1- DATA_GASES4("CHF3","R1")) * DATA_GASES4("CHF3","R_CF4") * (1-DATA_GASES4("CHF3","R_CHF3")))) * DATA_GASES4("CF4","GWP"))
         + (DATA_GASES3("C4F8",yeark) * (1- DATA_GASES4("C4F8","R1")) * DATA_GASES4("C4F8","R_C2F6") * (1-DATA_GASES4("C4F8","R_CHF3")) * DATA_GASES4("C4F8","GWP")) ;

Emit_Prcs(yeark,"HFCs","0226") = SUM(HFCS, (DATA_GASES3(HFCS,yeark) * (1- DATA_GASES4(HFCS,"R1")) * DATA_GASES4(HFCS,"R2") * (1-DATA_GASES4(HFCS,"R3")) * DATA_GASES4(HFCS,"GWP")) )
                                 + (DATA_GASES3("CHF3",yeark) * (1- DATA_GASES4("CHF3","R1")) * DATA_GASES4("CHF3","R4") * (1-DATA_GASES4("CHF3","R_CHF3")) * DATA_GASES4("CHF3","GWP")) ;
loop(yeark$(ord(yeark) ge 2), Emit_Prcs(yeark,"HFCs","0226") = SUM(HFCS, (DATA_GASES3(HFCS,yeark) * (1- DATA_GASES4(HFCS,"R1")) * DATA_GASES4(HFCS,"R2") * (1-DATA_GASES4(HFCS,"R3")) * DATA_GASES4(HFCS,"GWP")) )
                                 + (DATA_GASES3("c4f8",yeark) * 0.9 * 0.02 ) ; );

Emit_Prcs(yeark,"SF6","0226") = DATA_GASES3("SF6",yeark) * (1- DATA_GASES4("SF6","R1")) * DATA_GASES4("SF6","R2") * (1-DATA_GASES4("SF6","R3")) * DATA_GASES4("SF6","GWP")  ;
Emit_Prcs(yeark,"CO2","0226") = DATA_GASES3("CO2",yeark) * (1- DATA_GASES4("CO2","R1")) * (1-DATA_GASES4("CO2","R2")) * (1-DATA_GASES4("CO2","R3")) * DATA_GASES4("CO2","GWP")  ;
Emit_Prcs(yeark,"N2O","0226") = DATA_GASES3("N2O",yeark) * (1- DATA_GASES4("N2O","R1")) * (1-DATA_GASES4("N2O","R2")) * (1-DATA_GASES4("N2O","R3")) * DATA_GASES4("N2O","GWP")  ;


**전기장치 (2.F.8)
**전기장치 SF6 배출량
** Industry 0241=""Electric transformers". Total SF6-sum of other industry use of SF6
** In 2010 0241 "Electric transformers"= 0215
Emit_Prcs(yeark,"SF6","0215")$(Emit_Prcs(yeark,"SF6","0226")) = Emit_GIR(yeark,"p_halo_sf6") - sum(i_sec0, Emit_Prcs(yeark,"SF6",i_sec0)) ;

*******************************************
*장내발효(4.A), 가축분뇨처리(4.B)
*******************************************
Set Animals /DairlyCattle,BeefCattle,Pig,chicken,goat,sheep,horse,duck,deer/;
** Methan: estimate using cattle stock
Parameters Data_Animals(yeark,Animals), Data_EF_CCf(Animals), Data_MM_CCf(Animals) ;
**READ** 가축 사육 두수 (1,000두)
$LIBINCLUDE XLIMPORT Data_Animals emissions_estimation\GIR_Emissions.xlsx Enteric_fermentation(4.A)!A3..J44     ;
**READ** 가축 장내발효 과정의 CH4 배출계수 (kg CH4/두수/년)
$LIBINCLUDE XLIMPORT Data_EF_CCf emissions_estimation\GIR_Emissions.xlsx Enteric_fermentation(4.A)!P10..X11     ;
**READ** 가축 가축분뇨처리 과정의 CH4 배출계수 (kg CH4/두수/년)
$LIBINCLUDE XLIMPORT Data_MM_CCf emissions_estimation\GIR_Emissions.xlsx Mamure_management(4.B)!P10..X11     ;

** 0018=Dairy Farming, 0019=Beef, 0020=Pigs 0021=Poultry 0022=Other
** in 2010

*0018     "Dairy farming" => 0014
*0019     "Beef cattle" => 0015
*0020     "Pigs" => 0016
*0021     "Poultry and birds"=> 0017
*0022     "Other animals" => 0018

**장내발효 및 가축분뇨처리에 따른 낙농업 CH4 배출량 (ton CO2단위로 환산) (4.A, 4.B)
Emit_Prcs(yeark,"CH4","0014") = ( Data_EF_CCf("DairlyCattle") + Data_MM_CCf("DairlyCattle") ) * Data_Animals(yeark,"DairlyCattle") * GWP_CH4 ;
**장내발효 및 가축분뇨처리에 따른 육우 CH4 배출량 (ton CO2단위로 환산) (4.A, 4.B)
Emit_Prcs(yeark,"CH4","0015") = ( Data_EF_CCf("BeefCattle") + Data_MM_CCf("BeefCattle") ) * Data_Animals(yeark,"BeefCattle") * GWP_CH4 ;
**장내발효 및 가축분뇨처리에 따른 양돈업 CH4 배출량 (ton CO2단위로 환산) (4.A, 4.B)
Emit_Prcs(yeark,"CH4","0016") = ( Data_EF_CCf("Pig") + Data_MM_CCf("Pig") ) * Data_Animals(yeark,"Pig") * GWP_CH4 ;
**장내발효 및 가축분뇨처리에 따른 가금 CH4 배출량 (ton CO2단위로 환산) (4.A, 4.B)
Emit_Prcs(yeark,"CH4","0017") = (( Data_EF_CCf("chicken") + Data_MM_CCf("chicken") ) * Data_Animals(yeark,"chicken") * GWP_CH4 ) + (( Data_EF_CCf("duck") + Data_MM_CCf("duck") ) * Data_Animals(yeark,"duck") * GWP_CH4 )  ;
**장내발효 및 가축분뇨처리에 따른 기타축산 CH4 배출량 (ton CO2단위로 환산) (4.A, 4.B)
Emit_Prcs(yeark,"CH4","0018") = (( Data_EF_CCf("goat") + Data_MM_CCf("goat") ) * Data_Animals(yeark,"goat") * GWP_CH4 ) + (( Data_EF_CCf("sheep") + Data_MM_CCf("sheep") ) * Data_Animals(yeark,"sheep") * GWP_CH4 ) + (( Data_EF_CCf("horse") + Data_MM_CCf("horse") ) * Data_Animals(yeark,"horse") * GWP_CH4 ) + (( Data_EF_CCf("deer") + Data_MM_CCf("deer") ) * Data_Animals(yeark,"deer") * GWP_CH4 )  ;

** N20 GIR estimates are used
** 0018=Dairy Farming, 0019=Beef, 0020=Pigs 0021=Poultry 0022=Other
**가축분뇨처리에 따른 낙농업 N2O 배출량 (ton CO2 단위로 환산) (4.B)
if(not Prcs_ratio,
         Emit_Prcs(t,"N2O","0014")$(not told(t)) = Emit_GIR(t,"a_ferm_n2o") *
         xp_b0(t,"0014") / ( xp_b0(t,"0014") + xp_b0(t,"0015") + xp_b0(t,"0016") + xp_b0(t,"0017") + xp_b0(t,"0018") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"N2O","0014") = Emit_GIR(yeark,"a_ferm_n2o") *
         xp_b0(yeark,"0014") / ( xp_b0(yeark,"0014") + xp_b0(yeark,"0015") + xp_b0(yeark,"0016") + xp_b0(yeark,"0017") + xp_b0(yeark,"0018") ) ;);
         loop(yeark$(not t(yeark) and (xp_b0(yeark+1,"0014"))), Emit_Prcs(yeark,"N2O","0014") = Emit_GIR(yeark,"a_ferm_n2o") *
         xp_b0(yeark+1,"0014") / ( xp_b0(yeark+1,"0014") + xp_b0(yeark+1,"0015") + xp_b0(yeark+1,"0016") + xp_b0(yeark+1,"0017") + xp_b0(yeark+1,"0018") ) ;);
         loop(yeark$(not t(yeark) and not xp_b0(yeark+1,"0014")), Emit_Prcs(yeark,"N2O","0014") = Emit_GIR(yeark,"a_ferm_n2o") *
         xp_b0("2003","0014") / ( xp_b0("2003","0014") + xp_b0("2003","0015") + xp_b0("2003","0016") + xp_b0("2003","0017") + xp_b0("2003","0018") ) ;); );

**가축분뇨처리에 따른 육우 N2O 배출량 (ton CO2 단위로 환산) (4.B)
if(not Prcs_ratio,
         Emit_Prcs(t,"N2O","0015")$(not told(t)) = Emit_GIR(t,"a_ferm_n2o") *
         xp_b0(t,"0015") / ( xp_b0(t,"0014") + xp_b0(t,"0015") + xp_b0(t,"0016") + xp_b0(t,"0017") + xp_b0(t,"0018") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"N2O","0015") = Emit_GIR(yeark,"a_ferm_n2o") *
         xp_b0(yeark,"0015") / ( xp_b0(yeark,"0014") + xp_b0(yeark,"0015") + xp_b0(yeark,"0016") + xp_b0(yeark,"0017") + xp_b0(yeark,"0018") ) ;);
         loop(yeark$(not t(yeark) and (xp_b0(yeark+1,"0014"))), Emit_Prcs(yeark,"N2O","0015") = Emit_GIR(yeark,"a_ferm_n2o") *
         xp_b0(yeark+1,"0015") / ( xp_b0(yeark+1,"0014") + xp_b0(yeark+1,"0015") + xp_b0(yeark+1,"0016") + xp_b0(yeark+1,"0017") + xp_b0(yeark+1,"0018") ) ;);
         loop(yeark$(not t(yeark) and not xp_b0(yeark+1,"0014")), Emit_Prcs(yeark,"N2O","0015") = Emit_GIR(yeark,"a_ferm_n2o") *
         xp_b0("2003","0015") / ( xp_b0("2003","0014") + xp_b0("2003","0015") + xp_b0("2003","0016") + xp_b0("2003","0017") + xp_b0("2003","0018") ) ;); );

**가축분뇨처리에 따른 양돈업 N2O 배출량 (ton CO2 단위로 환산) (4.B)
if(not Prcs_ratio,
         Emit_Prcs(t,"N2O","0016")$(not told(t)) = Emit_GIR(t,"a_ferm_n2o") *
         xp_b0(t,"0016") / ( xp_b0(t,"0014") + xp_b0(t,"0015") + xp_b0(t,"0016") + xp_b0(t,"0017") + xp_b0(t,"0018") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"N2O","0016") = Emit_GIR(yeark,"a_ferm_n2o") *
         xp_b0(yeark,"0016") / ( xp_b0(yeark,"0014") + xp_b0(yeark,"0015") + xp_b0(yeark,"0016") + xp_b0(yeark,"0017") + xp_b0(yeark,"0018") ) ;);
         loop(yeark$(not t(yeark) and (xp_b0(yeark+1,"0014"))), Emit_Prcs(yeark,"N2O","0016") = Emit_GIR(yeark,"a_ferm_n2o") *
         xp_b0(yeark+1,"0016") / ( xp_b0(yeark+1,"0014") + xp_b0(yeark+1,"0015") + xp_b0(yeark+1,"0016") + xp_b0(yeark+1,"0017") + xp_b0(yeark+1,"0018") ) ;);
         loop(yeark$(not t(yeark) and not xp_b0(yeark+1,"0014")), Emit_Prcs(yeark,"N2O","0016") = Emit_GIR(yeark,"a_ferm_n2o") *
         xp_b0("2003","0016") / ( xp_b0("2003","0014") + xp_b0("2003","0015") + xp_b0("2003","0016") + xp_b0("2003","0017") + xp_b0("2003","0018") ) ;); );

**가축분뇨처리에 따른 가금 N2O 배출량 (ton CO2 단위로 환산) (4.B)
if(not Prcs_ratio,
         Emit_Prcs(t,"N2O","0017")$(not told(t)) = Emit_GIR(t,"a_ferm_n2o") *
         xp_b0(t,"0017") / ( xp_b0(t,"0014") + xp_b0(t,"0015") + xp_b0(t,"0016") + xp_b0(t,"0017") + xp_b0(t,"0018") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"N2O","0017") = Emit_GIR(yeark,"a_ferm_n2o") *
         xp_b0(yeark,"0017") / ( xp_b0(yeark,"0014") + xp_b0(yeark,"0015") + xp_b0(yeark,"0016") + xp_b0(yeark,"0017") + xp_b0(yeark,"0018") ) ;);
         loop(yeark$(not t(yeark) and (xp_b0(yeark+1,"0014"))), Emit_Prcs(yeark,"N2O","0017") = Emit_GIR(yeark,"a_ferm_n2o") *
         xp_b0(yeark+1,"0017") / ( xp_b0(yeark+1,"0014") + xp_b0(yeark+1,"0015") + xp_b0(yeark+1,"0016") + xp_b0(yeark+1,"0017") + xp_b0(yeark+1,"0018") ) ;);
         loop(yeark$(not t(yeark) and not xp_b0(yeark+1,"0014")), Emit_Prcs(yeark,"N2O","0017") = Emit_GIR(yeark,"a_ferm_n2o") *
         xp_b0("2003","0017") / ( xp_b0("2003","0014") + xp_b0("2003","0015") + xp_b0("2003","0016") + xp_b0("2003","0017") + xp_b0("2003","0018") ) ;); );

**가축분뇨처리에 따른 기타축산 N2O 배출량 (ton CO2 단위로 환산) (4.B)
if(not Prcs_ratio,
         Emit_Prcs(t,"N2O","0018")$(not told(t)) = Emit_GIR(t,"a_ferm_n2o") *
         xp_b0(t,"0018") / ( xp_b0(t,"0014") + xp_b0(t,"0015") + xp_b0(t,"0016") + xp_b0(t,"0017") + xp_b0(t,"0018") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"N2O","0018") = Emit_GIR(yeark,"a_ferm_n2o") *
         xp_b0(yeark,"0018") / ( xp_b0(yeark,"0014") + xp_b0(yeark,"0015") + xp_b0(yeark,"0016") + xp_b0(yeark,"0017") + xp_b0(yeark,"0018") ) ;);
         loop(yeark$(not t(yeark) and (xp_b0(yeark+1,"0014"))), Emit_Prcs(yeark,"N2O","0018") = Emit_GIR(yeark,"a_ferm_n2o") *
         xp_b0(yeark+1,"0018") / ( xp_b0(yeark+1,"0014") + xp_b0(yeark+1,"0015") + xp_b0(yeark+1,"0016") + xp_b0(yeark+1,"0017") + xp_b0(yeark+1,"0018") ) ;);
         loop(yeark$(not t(yeark) and not xp_b0(yeark+1,"0014")), Emit_Prcs(yeark,"N2O","0018") = Emit_GIR(yeark,"a_ferm_n2o") *
         xp_b0("2003","0018") / ( xp_b0("2003","0014") + xp_b0("2003","0015") + xp_b0("2003","0016") + xp_b0("2003","0017") + xp_b0("2003","0018") ) ;); );

**check if distribution is complete. X=sum(i, ai*X) sum(i,ai)=1
loop(yeark$(Emit_Prcs(yeark,"N2O","0014") or Emit_Prcs(yeark,"N2O","0015") or Emit_Prcs(yeark,"N2O","0016") or Emit_Prcs(yeark,"N2O","0017") or Emit_Prcs(yeark,"N2O","0018") ),
         if (abs(Emit_Prcs(yeark,"N2O","0014") + Emit_Prcs(yeark,"N2O","0015") + Emit_Prcs(yeark,"N2O","0016") + Emit_Prcs(yeark,"N2O","0017") + Emit_Prcs(yeark,"N2O","0018") - Emit_GIR(yeark,"a_ferm_n2o")  ) > 0.001 , Abort "Check the 4.B" ); );

*loop(yeark$(not tol_year(yeark)),
*if(abs(Emit_Prcs(yeark,"CH4","0018") + Emit_Prcs(yeark,"CH4","0019") + Emit_Prcs(yeark,"CH4","0020") + Emit_Prcs(yeark,"CH4","0021") + Emit_Prcs(yeark,"CH4","0022") - Emit_GIR(yeark,"a_ferm_ch4") - Emit_GIR(yeark,"a_man_ch4")) > 10000 , Abort "Check the 4.A or 4.B" ); );
parameter Emit_Animals(yeark) ;
Emit_Animals(yeark) = Emit_Prcs(yeark,"CH4","0014") + Emit_Prcs(yeark,"CH4","0015") + Emit_Prcs(yeark,"CH4","0016") + Emit_Prcs(yeark,"CH4","0017") + Emit_Prcs(yeark,"CH4","0018") ;
*******************************************
*농경지 경작(4.C)
*******************************************
** Methan in Rice(0001)
** IN 2010, 0001 => 0001
Emit_Prcs(yeark,"CH4","0001") = Emit_GIR(yeark,"a_farm_ch4") ;

*******************************************
*농경지(4.D)
*******************************************
Parameters Data_CheF(yeark), Data_LivM(yeark), Data_legu(yeark), Data_cropr(yeark), Data_indr(yeark) ;
**READ** 화학비료에 의한 N2O 배출량 (tCO2 eq)
$LIBINCLUDE XLIMPORT Data_CheF emissions_estimation\GIR_Emissions.xlsx Agricultural_Soils(4.D)!B2..AZ3     ;
**READ** 기축분뇨 의한 N2O 배출량 (tCO2 eq)
$LIBINCLUDE XLIMPORT Data_LivM emissions_estimation\GIR_Emissions.xlsx Agricultural_Soils(4.D)!B13..AZ14     ;
**READ** 두과작물에 의한 N2O 배출량 (tCO2 eq)
$LIBINCLUDE XLIMPORT Data_legu emissions_estimation\GIR_Emissions.xlsx Agricultural_Soils(4.D)!B24..AZ25     ;
**READ** 작물잔사환원에 의한 N2O 배출량 (tCO2 eq)
$LIBINCLUDE XLIMPORT Data_cropr emissions_estimation\GIR_Emissions.xlsx Agricultural_Soils(4.D)!B35..AZ36     ;
**READ** 간접 N2O 배출량 (tN2O)
$LIBINCLUDE XLIMPORT Data_indr emissions_estimation\GIR_Emissions.xlsx Agricultural_Soils(4.D)!B46..AZ47     ;
** Agriculture
set i_Agr(i_sec0) /0001,        0002,        0003,        0004,        0005,        0006,        0007,        0008,        0009,        0010,        0011,        0012,        0013,        0014,     0015,     0016,        0017,        0018 /;
** Crop
*0001     "Unmilled rice" => 0001 (2010)
*0002     "Barley" => 0002 (2010)
*0003     "Wheat" => 0002 (2010)
*0004     "Misc. cereals" => 0002 (2010)
*0005     "Vegetables" => 0005(2010)
*0006     "Fruits"  => 0006 (2010)
*0007     "Pulses"  => 0003 (2010)
*0008     "Potatoes" => 0004 (2010)
*0009     "Oleaginous crops" + *0011     "Other edible crops" => 0008 (2010)
*0010     "Cultivated medicinal herbs" =>0007 (2010)
*0012     "Cotton and hemp" + *0017     "Other Inedible crops"=> 0013 (2010)
*0013     "Leaf tobacco" => 0009 (2010)
*0014     "Horticultural specialities"=> 0010 (2010)
*0016     "Seeds and seedlings"=> 0012 (2010)
set i_crop(i_agr) /0001,        0002,        0003,        0004,        0005,        0006,        0007,        0008,        0009,        0010,       0012,        0013/ ;
** 0018=Dairy Farming, 0019=Beef, 0020=Pigs 0021=Poultry 0022=Other
set i_livs(i_agr) /  0014,        0015,        0016,        0017,        0018/ ;
*0001     "Unmilled rice"  => 0001 (2010)
*0002     "Barley" => 0002 (2010)
*0003     "Wheat" => 0002 (2010)
*0004     "Misc. cereals" => 0002 (2010)
*0008     "Potatoes"  => 0004 (2010)
set i_crop2(i_agr)/0001,        0002,         0004/;
*0001     "Unmilled rice" => 0001 (2010)
*0002     "Barley" => 0002 (2010)
*0003     "Wheat"  => 0002 (2010)
*0004     "Misc. cereals" => 0002 (2010)
*0008     "Potatoes" => 0004 (2010)
set i_crop3(i_agr)/0001,        0002,         0004/;


alias(i_agr,j_agr);
alias(i_crop,j_crop);
alias(i_livs,j_livs);
alias(i_crop2,j_crop2);
alias(i_crop3,j_crop3);

** 0153 (Fertilzer) in crops : Emission from fertilizer use
** 0153 =>  0123 in 2010
if(not Prcs_ratio,
         Emit_Prcs(t,"N2O",i_crop)$(not told(t)) = Emit_Prcs(t,"N2O",i_crop) + ( Data_CheF(t) * IOT_B0(t,"0123",i_crop) / sum(j_crop, IOT_B0(t,"0123",j_crop)) ) ; );
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"N2O",i_crop) =  Emit_Prcs(yeark,"N2O",i_crop) +
         ( Data_CheF(yeark) * IOT_B0(yeark,"0123",i_crop) / sum(j_crop, IOT_B0(yeark,"0123",j_crop)) ) ; );
         loop(yeark$(not t(yeark) and (sum(j_crop, IOT_B0(yeark+1,"0123",j_crop)))), Emit_Prcs(yeark,"N2O",i_crop) =  Emit_Prcs(yeark,"N2O",i_crop) +
         ( Data_CheF(yeark) * IOT_B0(yeark+1,"0123",i_crop) / sum(j_crop, IOT_B0(yeark+1,"0123",j_crop)) ) ; );
         loop(yeark$(not t(yeark) and not (sum(j_crop, IOT_B0(yeark+1,"0123",j_crop)))), Emit_Prcs(yeark,"N2O",i_crop) =  Emit_Prcs(yeark,"N2O",i_crop) +
         ( Data_CheF(yeark) * IOT_B0("2003","0123",i_crop) / sum(j_crop, IOT_B0("2003","0123",j_crop)) ) ; ););
** i_livs (Live stock) N20
if(not Prcs_ratio,
         Emit_Prcs(t,"N2O",i_livs)$(not told(t)) = Emit_Prcs(t,"N2O",i_livs) + ( Data_LivM(t) * xp_b0(t,i_livs) / sum(j_livs, xp_B0(t,j_livs)) ) ; );
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"N2O",i_livs) =  Emit_Prcs(yeark,"N2O",i_livs) +
         ( Data_LivM(yeark) * xp_b0(yeark,i_livs) / sum(j_livs, xp_B0(yeark,j_livs)) ) ; );
         loop(yeark$(not t(yeark) and (sum(j_livs, xp_B0(yeark+1,j_livs)))), Emit_Prcs(yeark,"N2O",i_livs) =  Emit_Prcs(yeark,"N2O",i_livs) +
         ( Data_LivM(yeark) * xp_b0(yeark+1,i_livs) / sum(j_livs, xp_B0(yeark+1,j_livs)) ) ; );
         loop(yeark$(not t(yeark) and not (sum(j_livs, xp_B0(yeark+1,j_livs)))), Emit_Prcs(yeark,"N2O",i_livs) =  Emit_Prcs(yeark,"N2O",i_livs) +
         ( Data_LivM(yeark) * xp_b0("2003",i_livs) / sum(j_livs, xp_B0("2003",j_livs)) ) ; ); );
** N2o from non-vegi crops (crop2)
if(not Prcs_ratio,
         Emit_Prcs(t,"N2O",i_crop2)$(not told(t)) = Emit_Prcs(t,"N2O",i_crop2) + ( Data_legu(t) * xp_b0(t,i_crop2) / sum(j_crop2, xp_B0(t,j_crop2)) ) ; );
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"N2O",i_crop2) =  Emit_Prcs(yeark,"N2O",i_crop2) +
         ( Data_legu(yeark) * xp_b0(yeark,i_crop2) / sum(j_crop2, xp_B0(yeark,j_crop2)) ) ; );
         loop(yeark$(not t(yeark) and (sum(j_crop2, xp_B0(yeark+1,j_crop2)))), Emit_Prcs(yeark,"N2O",i_crop2) =  Emit_Prcs(yeark,"N2O",i_crop2) +
         ( Data_legu(yeark) * xp_b0(yeark+1,i_crop2) / sum(j_crop2, xp_B0(yeark+1,j_crop2)) ) ; );
         loop(yeark$(not t(yeark) and not (sum(j_crop2, xp_B0(yeark+1,j_crop2)))), Emit_Prcs(yeark,"N2O",i_crop2) =  Emit_Prcs(yeark,"N2O",i_crop2) +
         ( Data_legu(yeark) * xp_b0("2003",i_crop2) / sum(j_crop2, xp_B0("2003",j_crop2)) ) ; ); );
** N2o from straws (crop3: straw yielding crops)
if(not Prcs_ratio,
         Emit_Prcs(t,"N2O",i_crop3)$(not told(t)) = Emit_Prcs(t,"N2O",i_crop3) + ( Data_cropr(t) * xp_b0(t,i_crop3) / sum(j_crop3, xp_B0(t,j_crop3)) ) ; );
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"N2O",i_crop3) =  Emit_Prcs(yeark,"N2O",i_crop3) +
         ( Data_cropr(yeark) * xp_b0(yeark,i_crop3) / sum(j_crop3, xp_B0(yeark,j_crop3)) ) ; );
         loop(yeark$(not t(yeark) and (sum(j_crop3, xp_B0(yeark+1,j_crop3)))), Emit_Prcs(yeark,"N2O",i_crop3) =  Emit_Prcs(yeark,"N2O",i_crop3) +
         ( Data_cropr(yeark) * xp_b0(yeark+1,i_crop3) / sum(j_crop3, xp_B0(yeark+1,j_crop3)) ) ; );
         loop(yeark$(not t(yeark) and not (sum(j_crop3, xp_B0(yeark+1,j_crop3)))), Emit_Prcs(yeark,"N2O",i_crop3) =  Emit_Prcs(yeark,"N2O",i_crop3) +
         ( Data_cropr(yeark) * xp_b0("2003",i_crop3) / sum(j_crop3, xp_B0("2003",j_crop3)) ) ; ); );
**indirect N2o all agriculture
if(not Prcs_ratio,
         Emit_Prcs(t,"N2O",i_agr)$(not told(t)) = Emit_Prcs(t,"N2O",i_agr) + ( Data_indr(t)* GWP_N2O * xp_b0(t,i_agr) / sum(j_agr, xp_B0(t,j_agr)) ) ; );
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"N2O",i_agr) =  Emit_Prcs(yeark,"N2O",i_agr) +
         ( Data_indr(yeark) * GWP_N2O * xp_b0(yeark,i_agr) / sum(j_agr, xp_B0(yeark,j_agr)) ) ; );
         loop(yeark$(not t(yeark) and (sum(j_agr, xp_B0(yeark+1,j_agr)))), Emit_Prcs(yeark,"N2O",i_agr) =  Emit_Prcs(yeark,"N2O",i_agr) +
         ( Data_indr(yeark) * GWP_N2O  * xp_b0(yeark+1,i_agr) / sum(j_agr, xp_B0(yeark+1,j_agr)) ) ; );
         loop(yeark$(not t(yeark) and not (sum(j_agr, xp_B0(yeark+1,j_agr)))), Emit_Prcs(yeark,"N2O",i_agr) =  Emit_Prcs(yeark,"N2O",i_agr) +
         ( Data_indr(yeark) * GWP_N2O  * xp_b0("2003",i_agr) / sum(j_agr, xp_B0("2003",j_agr)) ) ; ); );

*******************************************
*작물잔사소각(4.F) (Buring residues)
*******************************************
* CH4
** 0001 Rice
**작물잔사 소각에 따른 벼 CH4 배출량 (ton CO2 단위로 환산) (4.F)
if(not Prcs_ratio,
          Emit_Prcs(t,"CH4","0001")$(not told(t)) = Emit_Prcs(t,"CH4","0001") + Emit_GIR(t,"a_res_ch4") *
         xp_b0(t,"0001") / ( xp_b0(t,"0001") + xp_b0(t,"0002") + xp_b0(t,"0005") + xp_b0(t,"0003") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"CH4","0001") = Emit_Prcs(yeark,"CH4","0001") + Emit_GIR(yeark,"a_res_ch4") *
         xp_b0(yeark,"0001") / ( xp_b0(yeark,"0001") + xp_b0(yeark,"0002") + xp_b0(yeark,"0005") + xp_b0(yeark,"0003") ) ;);
         loop(yeark$(not t(yeark) and (xp_b0(yeark+1,"0001"))), Emit_Prcs(yeark,"CH4","0001") = Emit_Prcs(yeark,"CH4","0001") + Emit_GIR(yeark,"a_res_ch4") *
         xp_b0(yeark+1,"0001") / ( xp_b0(yeark+1,"0001") + xp_b0(yeark+1,"0002") + xp_b0(yeark+1,"0005") + xp_b0(yeark+1,"0003") ) ;);
         loop(yeark$(not t(yeark) and not xp_b0(yeark+1,"0001")), Emit_Prcs(yeark,"CH4","0001") = Emit_Prcs(yeark,"CH4","0001") + Emit_GIR(yeark,"a_res_ch4") *
         xp_b0("2003","0001") / ( xp_b0("2003","0001") + xp_b0("2003","0002")+ xp_b0("2003","0005") + xp_b0("2003","0003") ) ;););

******* in 2010, 0002 and 0003 should be merged into 0002 *******
** 0002 Barley, 0003 Wheat   => 0002
**작물잔사 소각에 따른 보리 CH4 배출량 (ton CO2 단위로 환산) (4.F)
if(not Prcs_ratio,
          Emit_Prcs(t,"CH4","0002")$(not told(t)) = Emit_GIR(t,"a_res_ch4") *
         xp_b0(t,"0002") / ( xp_b0(t,"0001")+ xp_b0(t,"0002") + xp_b0(t,"0005") + xp_b0(t,"0003") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"CH4","0002") = Emit_GIR(yeark,"a_res_ch4") *
         xp_b0(yeark,"0002") / ( xp_b0(yeark,"0001") + xp_b0(yeark,"0002") + xp_b0(yeark,"0005") + xp_b0(yeark,"0003") ) ;);
         loop(yeark$(not t(yeark) and (xp_b0(yeark+1,"0001"))), Emit_Prcs(yeark,"CH4","0002") = Emit_GIR(yeark,"a_res_ch4") *
         xp_b0(yeark+1,"0002") / ( xp_b0(yeark+1,"0001") + xp_b0(yeark+1,"0002") + xp_b0(yeark+1,"0005") + xp_b0(yeark+1,"0003") ) ;);
         loop(yeark$(not t(yeark) and not xp_b0(yeark+1,"0001")), Emit_Prcs(yeark,"CH4","0002") = Emit_GIR(yeark,"a_res_ch4") *
         xp_b0("2003","0002") / ( xp_b0("2003","0001") + xp_b0("2003","0002") + xp_b0("2003","0005") + xp_b0("2003","0003") ) ;););
** 0003 Wheat
**작물잔사 소각에 따른 밀 CH4 배출량 (ton CO2 단위로 환산) (4.F)
if(not Prcs_ratio,
         Emit_Prcs(t,"CH4","0002")$(not told(t)) = Emit_GIR(t,"a_res_ch4") *
         xp_b0(t,"0002") / ( xp_b0(t,"0001") + xp_b0(t,"0002") + xp_b0(t,"0005") + xp_b0(t,"0003") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"CH4","0002") = Emit_GIR(yeark,"a_res_ch4") *
         xp_b0(yeark,"0002") / ( xp_b0(yeark,"0001")  + xp_b0(yeark,"0002") + xp_b0(yeark,"0005") + xp_b0(yeark,"0003") ) ;);
         loop(yeark$(not t(yeark) and (xp_b0(yeark+1,"0001"))), Emit_Prcs(yeark,"CH4","0002") = Emit_GIR(yeark,"a_res_ch4") *
         xp_b0(yeark+1,"0002") / ( xp_b0(yeark+1,"0001") + xp_b0(yeark+1,"0002") + xp_b0(yeark+1,"0005") + xp_b0(yeark+1,"0003") ) ;);
         loop(yeark$(not t(yeark) and not xp_b0(yeark+1,"0001")), Emit_Prcs(yeark,"CH4","0002") = Emit_GIR(yeark,"a_res_ch4") *
         xp_b0("2003","0002") / ( xp_b0("2003","0001") + xp_b0("2003","0002") + xp_b0("2003","0005") + xp_b0("2003","0003") ) ;););

** 0005 Vegi => 0005 in 2010
**작물잔사 소각에 따른 채소 CH4 배출량 (ton CO2 단위로 환산) (4.F)
if(not Prcs_ratio,
         Emit_Prcs(t,"CH4","0005")$(not told(t)) = Emit_GIR(t,"a_res_ch4") *
         xp_b0(t,"0005") / ( xp_b0(t,"0001") + xp_b0(t,"0002") + xp_b0(t,"0005") + xp_b0(t,"0003") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"CH4","0005") = Emit_GIR(yeark,"a_res_ch4") *
         xp_b0(yeark,"0005") / ( xp_b0(yeark,"0001")  + xp_b0(yeark,"0002") + xp_b0(yeark,"0005") + xp_b0(yeark,"0003") ) ;);
         loop(yeark$(not t(yeark) and (xp_b0(yeark+1,"0001"))), Emit_Prcs(yeark,"CH4","0005") = Emit_GIR(yeark,"a_res_ch4") *
         xp_b0(yeark+1,"0005") / ( xp_b0(yeark+1,"0001")  + xp_b0(yeark+1,"0002") + xp_b0(yeark+1,"0005") + xp_b0(yeark+1,"0003") ) ;);
         loop(yeark$(not t(yeark) and not xp_b0(yeark+1,"0001")), Emit_Prcs(yeark,"CH4","0005") = Emit_GIR(yeark,"a_res_ch4") *
         xp_b0("2003","0005") / ( xp_b0("2003","0001") + xp_b0("2003","0002") + xp_b0("2003","0005") + xp_b0("2003","0003") ) ;););
** 0007 Pulses (beans) =>  0003 in 2010
**작물잔사 소각에 따른 콩류 CH4 배출량 (ton CO2 단위로 환산) (4.F)
if(not Prcs_ratio,
         Emit_Prcs(t,"CH4","0003")$(not told(t)) = Emit_GIR(t,"a_res_ch4") *
         xp_b0(t,"0003") / ( xp_b0(t,"0001") + xp_b0(t,"0002") + xp_b0(t,"0005") + xp_b0(t,"0003") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"CH4","0003") = Emit_GIR(yeark,"a_res_ch4") *
         xp_b0(yeark,"0003") / ( xp_b0(yeark,"0001") + xp_b0(yeark,"0002") + xp_b0(yeark,"0005") + xp_b0(yeark,"0003") ) ;);
         loop(yeark$(not t(yeark) and (xp_b0(yeark+1,"0001"))), Emit_Prcs(yeark,"CH4","0003") = Emit_GIR(yeark,"a_res_ch4") *
         xp_b0(yeark+1,"0003") / ( xp_b0(yeark+1,"0001") + xp_b0(yeark+1,"0002") + xp_b0(yeark+1,"0005") + xp_b0(yeark+1,"0003") ) ;);
         loop(yeark$(not t(yeark) and not xp_b0(yeark+1,"0001")), Emit_Prcs(yeark,"CH4","0003") = Emit_GIR(yeark,"a_res_ch4") *
         xp_b0("2003","0003") / ( xp_b0("2003","0001") + xp_b0("2003","0002") + xp_b0("2003","0005") + xp_b0("2003","0003") ) ;););

*N2o
** 0001 Rice =>0001 in 2010
**작물잔사 소각에 따른 벼 N2O 배출량 (ton CO2 단위로 환산) (4.F)
if(not Prcs_ratio,
         Emit_Prcs(t,"N2O","0001")$(not told(t)) = Emit_Prcs(t,"N2O","0001") + Emit_GIR(t,"a_res_N2O") *
         xp_b0(t,"0001") / ( xp_b0(t,"0001") + xp_b0(t,"0002") + xp_b0(t,"0005") + xp_b0(t,"0003") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"N2O","0001") = Emit_Prcs(yeark,"N2O","0001") + Emit_GIR(yeark,"a_res_N2O") *
         xp_b0(yeark,"0001") / ( xp_b0(yeark,"0001") + xp_b0(yeark,"0002") + xp_b0(yeark,"0005") + xp_b0(yeark,"0003") ) ;);
         loop(yeark$(not t(yeark) and (xp_b0(yeark+1,"0001"))), Emit_Prcs(yeark,"N2O","0001") = Emit_Prcs(yeark,"N2O","0001") + Emit_GIR(yeark,"a_res_N2O") *
         xp_b0(yeark+1,"0001") / ( xp_b0(yeark+1,"0001")+ xp_b0(yeark+1,"0002") + xp_b0(yeark+1,"0005") + xp_b0(yeark+1,"0003") ) ;);
         loop(yeark$(not t(yeark) and not xp_b0(yeark+1,"0001")), Emit_Prcs(yeark,"N2O","0001") = Emit_Prcs(yeark,"N2O","0001") + Emit_GIR(yeark,"a_res_N2O") *
         xp_b0("2003","0001") / ( xp_b0("2003","0001") + xp_b0("2003","0002") + xp_b0("2003","0005") + xp_b0("2003","0003") ) ;););
******* in 2010, 0002 and 0003 should be merged into 0002 *******
** 0002 Barley
**작물잔사 소각에 따른 보리 N2O 배출량 (ton CO2 단위로 환산) (4.F)
if(not Prcs_ratio,
         Emit_Prcs(t,"N2O","0002")$(not told(t)) = Emit_Prcs(t,"N2O","0002") + Emit_GIR(t,"a_res_N2O") *
         xp_b0(t,"0002") / ( xp_b0(t,"0001") + xp_b0(t,"0002")  + xp_b0(t,"0005") + xp_b0(t,"0003") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"N2O","0002") = Emit_Prcs(yeark,"N2O","0002") + Emit_GIR(yeark,"a_res_N2O") *
         xp_b0(yeark,"0002") / ( xp_b0(yeark,"0001") + xp_b0(yeark,"0002") + xp_b0(yeark,"0005") + xp_b0(yeark,"0003") ) ;);
         loop(yeark$(not t(yeark) and (xp_b0(yeark+1,"0001"))), Emit_Prcs(yeark,"N2O","0002") = Emit_Prcs(yeark,"N2O","0002") + Emit_GIR(yeark,"a_res_N2O") *
         xp_b0(yeark+1,"0002") / ( xp_b0(yeark+1,"0001") + xp_b0(yeark+1,"0002") + xp_b0(yeark+1,"0005") + xp_b0(yeark+1,"0003") ) ;);
         loop(yeark$(not t(yeark) and not xp_b0(yeark+1,"0001")), Emit_Prcs(yeark,"N2O","0002") = Emit_Prcs(yeark,"N2O","0002") + Emit_GIR(yeark,"a_res_N2O") *
         xp_b0("2003","0002") / ( xp_b0("2003","0001") + xp_b0("2003","0002") + xp_b0("2003","0005") + xp_b0("2003","0003") ) ;););
** 0003 Wheat
**작물잔사 소각에 따른 밀 N2O 배출량 (ton CO2 단위로 환산) (4.F)
if(not Prcs_ratio,
         Emit_Prcs(t,"N2O","0002")$(not told(t)) = Emit_Prcs(t,"N2O","0002") + Emit_GIR(t,"a_res_N2O") *
         xp_b0(t,"0002") / ( xp_b0(t,"0001") + xp_b0(t,"0002") + xp_b0(t,"0005") + xp_b0(t,"0003") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"N2O","0002") = Emit_Prcs(yeark,"N2O","0002") + Emit_GIR(yeark,"a_res_N2O") *
         xp_b0(yeark,"0002") / ( xp_b0(yeark,"0001") + xp_b0(yeark,"0002") + xp_b0(yeark,"0005") + xp_b0(yeark,"0003") ) ;);
         loop(yeark$(not t(yeark) and (xp_b0(yeark+1,"0001"))), Emit_Prcs(yeark,"N2O","0002") = Emit_Prcs(yeark,"N2O","0002") + Emit_GIR(yeark,"a_res_N2O") *
         xp_b0(yeark+1,"0002") / ( xp_b0(yeark+1,"0001")  + xp_b0(yeark+1,"0002") + xp_b0(yeark+1,"0005") + xp_b0(yeark+1,"0003") ) ;);
         loop(yeark$(not t(yeark) and not xp_b0(yeark+1,"0001")), Emit_Prcs(yeark,"N2O","0002") = Emit_Prcs(yeark,"N2O","0002") + Emit_GIR(yeark,"a_res_N2O") *
         xp_b0("2003","0002") / ( xp_b0("2003","0001") + xp_b0("2003","0002") + xp_b0("2003","0005") + xp_b0("2003","0003") ) ;););

** 0005 Vegi => 0005 in 2010
**작물잔사 소각에 따른 채소 N2O 배출량 (ton CO2 단위로 환산) (4.F)
if(not Prcs_ratio,
         Emit_Prcs(t,"N2O","0005")$(not told(t)) = Emit_Prcs(t,"N2O","0005") + Emit_GIR(t,"a_res_N2O") *
         xp_b0(t,"0005") / ( xp_b0(t,"0001") + xp_b0(t,"0002") + xp_b0(t,"0005") + xp_b0(t,"0003") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"N2O","0005") = Emit_Prcs(yeark,"N2O","0005") + Emit_GIR(yeark,"a_res_N2O") *
         xp_b0(yeark,"0005") / ( xp_b0(yeark,"0001") + xp_b0(yeark,"0002") + xp_b0(yeark,"0005") + xp_b0(yeark,"0003") ) ;);
         loop(yeark$(not t(yeark) and (xp_b0(yeark+1,"0001"))), Emit_Prcs(yeark,"N2O","0005") = Emit_Prcs(yeark,"N2O","0005") + Emit_GIR(yeark,"a_res_N2O") *
         xp_b0(yeark+1,"0005") / ( xp_b0(yeark+1,"0001") +  xp_b0(yeark+1,"0002") + xp_b0(yeark+1,"0005") + xp_b0(yeark+1,"0003") ) ;);
         loop(yeark$(not t(yeark) and not xp_b0(yeark+1,"0001")), Emit_Prcs(yeark,"N2O","0005") = Emit_Prcs(yeark,"N2O","0005") + Emit_GIR(yeark,"a_res_N2O") *
         xp_b0("2003","0005") / ( xp_b0("2003","0001") + xp_b0("2003","0002") + xp_b0("2003","0005") + xp_b0("2003","0003") ) ;););

** 0007 Pulses(beans) => 0003 in 2010
**작물잔사 소각에 따른 콩류 N2O 배출량 (ton CO2 단위로 환산) (4.F)
if(not Prcs_ratio,
         Emit_Prcs(t,"N2O","0003")$(not told(t)) =  Emit_Prcs(t,"N2O","0005") + Emit_GIR(t,"a_res_N2O") *
         xp_b0(t,"0003") / ( xp_b0(t,"0001") + xp_b0(t,"0002") + xp_b0(t,"0005") + xp_b0(t,"0003") ) ;);
if(Prcs_ratio,
         loop(yeark$t(yeark), Emit_Prcs(yeark,"N2O","0003") = Emit_Prcs(yeark,"N2O","0003") + Emit_GIR(yeark,"a_res_N2O") *
         xp_b0(yeark,"0003") / ( xp_b0(yeark,"0001")  + xp_b0(yeark,"0002") + xp_b0(yeark,"0005") + xp_b0(yeark,"0003") ) ;);
         loop(yeark$(not t(yeark) and (xp_b0(yeark+1,"0001"))), Emit_Prcs(yeark,"N2O","0003") = Emit_Prcs(yeark,"N2O","0003") + Emit_GIR(yeark,"a_res_N2O") *
         xp_b0(yeark+1,"0003") / ( xp_b0(yeark+1,"0001") + xp_b0(yeark+1,"0002") + xp_b0(yeark+1,"0005") + xp_b0(yeark+1,"0003") ) ;);
         loop(yeark$(not t(yeark) and not xp_b0(yeark+1,"0001")), Emit_Prcs(yeark,"N2O","0003") = Emit_Prcs(yeark,"N2O","0003") + Emit_GIR(yeark,"a_res_N2O") *
         xp_b0("2003","0003") / ( xp_b0("2003","0001") + xp_b0("2003","0002") + xp_b0("2003","0005") + xp_b0("2003","0003") ) ;););


*******************************************
*폐기물 소각(6)
*0382=Sanitory public => 0284 waste public
*0383 Sanitory commercial => 0285 waste commercial
*******************************************

*산업폐수는 제외하고 계산
**READ** 산업폐수 CH4 배출량 (tCO2 단위로 환산)
parameter DATA_iww(yeark) ;
$LIBINCLUDE XLIMPORT DATA_iww emissions_estimation\GIR_Emissions.xlsx Waste(6)!G3..AZ4 ;

if(not Prcs_ratio,
         Emit_Prcs(t,"CO2","0284")$(not told(t)) = Emit_GIR(t,"w_total_co2") *
         XP_B0(t,"0284") / ( XP_B0(t,"0284") + XP_B0(t,"0285") ) ;
         Emit_Prcs(t,"CO2","0285")$(not told(t)) = Emit_GIR(t,"w_total_co2")*
         XP_B0(t,"0285") / ( XP_B0(t,"0284") + XP_B0(t,"0285") ) ;

         Emit_Prcs(t,"CH4","0284")$(not told(t)) = ( Emit_GIR(t,"w_total_ch4") - DATA_iww(t) ) *
         XP_B0(t,"0284") / ( XP_B0(t,"0284") + XP_B0(t,"0285") ) ;
         Emit_Prcs(t,"CH4","0285")$(not told(t)) = ( Emit_GIR(t,"w_total_ch4") - DATA_iww(t) ) *
         XP_B0(t,"0285") / ( XP_B0(t,"0284") + XP_B0(t,"0285") ) ;

         Emit_Prcs(t,"N2O","0284")$(not told(t)) = Emit_GIR(t,"w_total_n2o") *
         XP_B0(t,"0284") / ( XP_B0(t,"0284") + XP_B0(t,"0285") ) ;
         Emit_Prcs(t,"N2O","0285")$(not told(t)) = Emit_GIR(t,"w_total_n2o") *
         XP_B0(t,"0285") / ( XP_B0(t,"0284") + XP_B0(t,"0285") ) ;

);

if(Prcs_ratio,
         loop(yeark$t(yeark),
         Emit_Prcs(yeark,"CO2","0284") = Emit_GIR(yeark,"w_total_co2") *
         XP_B0(yeark,"0284") / ( XP_B0(yeark,"0284") + XP_B0(yeark,"0285") ) ;
         Emit_Prcs(yeark,"CO2","0285") = Emit_GIR(yeark,"w_total_co2")*
         XP_B0(yeark,"0285") / ( XP_B0(yeark,"0284") + XP_B0(yeark,"0285") ) ;

         Emit_Prcs(yeark,"CH4","0284") = ( Emit_GIR(yeark,"w_total_ch4") - DATA_iww(yeark) ) *
         XP_B0(yeark,"0284") / ( XP_B0(yeark,"0284") + XP_B0(yeark,"0285") ) ;
         Emit_Prcs(yeark,"CH4","0285") = ( Emit_GIR(yeark,"w_total_ch4") - DATA_iww(yeark) ) *
         XP_B0(yeark,"0285") / ( XP_B0(yeark,"0284") + XP_B0(yeark,"0285") ) ;

         Emit_Prcs(yeark,"N2O","0284") = Emit_GIR(yeark,"w_total_n2o") *
         XP_B0(yeark,"0284") / ( XP_B0(yeark,"0284") + XP_B0(yeark,"0285") ) ;
         Emit_Prcs(yeark,"N2O","0285") = Emit_GIR(yeark,"w_total_n2o") *
         XP_B0(yeark,"0285") / ( XP_B0(yeark,"0284") + XP_B0(yeark,"0285") ) ;
         );

         loop(yeark$(not t(yeark) and (XP_B0(YEARK+1,"0285"))),
         Emit_Prcs(yeark,"CO2","0284") = Emit_GIR(yeark,"w_total_co2") *
         XP_B0(YEARK+1,"0284") / ( XP_B0(YEARK+1,"0284") + XP_B0(YEARK+1,"0285") ) ;
         Emit_Prcs(yeark,"CO2","0285") = Emit_GIR(yeark,"w_total_co2")*
         XP_B0(YEARK+1,"0285") / ( XP_B0(YEARK+1,"0284") + XP_B0(YEARK+1,"0285") ) ;

         Emit_Prcs(yeark,"CH4","0284") = ( Emit_GIR(yeark,"w_total_ch4") - DATA_iww(yeark) ) *
         XP_B0(YEARK+1,"0284") / ( XP_B0(YEARK+1,"0284") + XP_B0(YEARK+1,"0285") ) ;
         Emit_Prcs(yeark,"CH4","0285") = ( Emit_GIR(yeark,"w_total_ch4") - DATA_iww(yeark) ) *
         XP_B0(YEARK+1,"0285") / ( XP_B0(YEARK+1,"0284") + XP_B0(YEARK+1,"0285") ) ;

         Emit_Prcs(yeark,"N2O","0284") = Emit_GIR(yeark,"w_total_n2o") *
         XP_B0(YEARK+1,"0284") / ( XP_B0(YEARK+1,"0284") + XP_B0(YEARK+1,"0285") ) ;
         Emit_Prcs(yeark,"N2O","0285") = Emit_GIR(yeark,"w_total_n2o") *
         XP_B0(YEARK+1,"0285") / ( XP_B0(YEARK+1,"0284") + XP_B0(YEARK+1,"0285") ) ;
         );

         loop(yeark$(not t(yeark) and (not XP_B0(YEARK+1,"0285"))),
         Emit_Prcs(yeark,"CO2","0284") = Emit_GIR(yeark,"w_total_co2") *
         XP_B0("2003","0284") / ( XP_B0("2003","0284") + XP_B0("2003","0285") ) ;
         Emit_Prcs(yeark,"CO2","0285") = Emit_GIR(yeark,"w_total_co2")*
         XP_B0("2003","0285") / ( XP_B0("2003","0284") + XP_B0("2003","0285") ) ;

         Emit_Prcs(yeark,"CH4","0284") = ( Emit_GIR(yeark,"w_total_ch4") - DATA_iww(yeark) ) *
         XP_B0("2003","0284") / ( XP_B0("2003","0284") + XP_B0("2003","0285") ) ;
         Emit_Prcs(yeark,"CH4","0285") = ( Emit_GIR(yeark,"w_total_ch4") - DATA_iww(yeark) ) *
         XP_B0("2003","0285") / ( XP_B0("2003","0284") + XP_B0("2003","0285") ) ;

         Emit_Prcs(yeark,"N2O","0284") = Emit_GIR(yeark,"w_total_n2o") *
         XP_B0("2003","0284") / ( XP_B0("2003","0284") + XP_B0("2003","0285") ) ;
         Emit_Prcs(yeark,"N2O","0285") = Emit_GIR(yeark,"w_total_n2o") *
         XP_B0("2003","0285") / ( XP_B0("2003","0284") + XP_B0("2003","0285") ) ;
         ););



loop(yeark$(not Data_Clk(yeark) or not Data_Lst(yeark) or not Data_Dlm(yeark) or not Data_Sa(yeark) or not Data_CB(yeark) or not Data_Et(yeark) or not Data_CEt(yeark) or not Data_St(yeark) or not Data_CE(yeark) or not Data_CheF(yeark) or not Data_LivM(yeark) or not Data_legu(yeark) or not Data_cropr(yeark) or not Data_indr(yeark)),
Emit_Prcs(yeark,GHGs,i_sec0) = 0) ;

loop(yeark, loop(animals$(not Data_Animals(yeark,animals)), Emit_Prcs(yeark,GHGs,i_sec0) = 0); );
loop(yeark$(not sum(gases, DATA_GASES1(gases,yeark)) or not sum(gases, DATA_GASES3(gases,yeark))), Emit_Prcs(yeark,GHGs,i_sec0) = 0);

*loop(yeark$(yeark gt 2010), loop(emit_s$(not Emit_GIR(yeark,Emit_S)), Emit_Prcs(yeark,GHGs,i_s) = 0); );

parameter Prcs_GHG(yeark,i_sec0);
Prcs_GHG(yeark,i_sec0) = sum(GHGs, Emit_Prcs(yeark,GHGs,i_sec0)) ;
