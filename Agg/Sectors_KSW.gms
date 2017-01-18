*** 2015.7.2 mapi_sec0 mapping didn't have Transp. But mapi_G had. Fixed this inconsistency. 304-317 is now mapped to Transp.
Set i_s Original All Sectors/
M001
M002
M003
M004
M005
M006
M007
M008
M009
M010
M011
M012
M013
M014
M015
M016
M017
M018
M019
M020
M021
M022
M023
M024
M025
M026
M027
M028
M029
M030
M031
M032
M033
M034
M035
M036
M037
M038
M039
M040
M041
M042
M043
M044
M045
M046
M047
M048
M049
M050
M051
M052
M053
M054
M055
M056
M057
M058
M059
M060
M061
M062
M063
M064
M065
M066
M067
M068
M069
M070
M071
M072
M073
M074
M075
M076
M077
M078
M079
M080
M081
M082

resin
labor
dep
surplus
subsidy
PTAX

Final_Pc           "Private consumption expenditures"
Final_Gc           "Government consumption expenditures"
Final_Pk        "Gross private fixed capital formation"
Final_Gk        "Gross government fixed capital formation"
Final_St        "Increase in stocks"
Final_Ex        "Exports"
Final_Tot        "Total final demand"
/;

alias(i_s,j_s);
alias(i_s,k_s);

set i0 Sector Classification being used in the CGE model /
Agri
Mining
FoodPr
LumProd
TexWear
Petrol
ChemPla
MinMet
Macheqp
EleEqp
Vehicle
Manufac
Electri
GasWat
Const
TradSer
Transp
BusiSer
PubSer
/ ;

alias(i0,j0);
alias(i0,k0);
alias(i0,marg_comm);
alias(i0,i,j);

set mapi_G(i_s,i0) mapping between i_s and i0 /
M001.Agri
M002.Agri
M003.Agri
M004.Agri
M005.Agri
M006.Mining
M007.Mining
M008.FoodPr
M009.FoodPr
M010.FoodPr
M011.TexWear
M012.TexWear
M013.LumProd
M014.LumProd
M015.LumProd
M016.Petrol
M017.ChemPla
M018.ChemPla
M019.TexWear
M020.ChemPla
M021.ChemPla
M022.ChemPla
M023.ChemPla
M024.ChemPla
M025.MinMet
M026.MinMet
M027.MinMet
M028.MinMet
M029.MinMet
M030.MinMet
M031.MinMet
M032.Macheqp
M033.Macheqp
M034.Macheqp
M035.Macheqp
M036.Macheqp
M037.Macheqp
M038.EleEqp
M039.EleEqp
M040.MachEqp
M041.MachEqp
M042.Vehicle
M043.Vehicle
M044.Vehicle
M045.Manufac
M046.Electri
M047.GasWat
M048.GasWat
M049.PubSer
M050.PubSer
M051.Const
M052.Const
M053.TradSer
M054.Transp
M055.Transp
M056.Transp
M057.Transp
M058.TradSer
M059.TradSer
M060.BusiSer
M061.BusiSer
M062.BusiSer
M063.BusiSer
M064.BusiSer
M065.BusiSer
M066.BusiSer
M067.BusiSer
M068.BusiSer
M069.BusiSer
M070.BusiSer
M071.PubSer
M072.BusiSer
M073.BusiSer
M074.BusiSer
M075.PubSer
M076.PubSer
M077.PubSer
M078.PubSer
M079.PubSer
M080.BusiSer
M081.BusiSer
M082.BusiSer
/;


set TRANSPT(i_s) Transportation Sectors/
M055
M056
/;

set i0_TR(i0) Transportation Sectors in the i0 /
Transp
/

set mapi_TRANS(TRANSPT,i0_TR) Mapping between Transportation Sectors for Building the variable VST /
M055.Transp
M056.Transp
/;

$ontext
set ERG_COMM(i0) Energy commodity/
Coal
CrudeOil
NaturGas
oilpro
coalpro
Electrcity
fossl
nucle
othel
GasDistr
/
$offtext

set Fin_Demand(i_s) Final Demand Category/
Final_Pc           "Private consumption expenditures"
Final_Gc           "Government consumption expenditures"
Final_Pk        "Gross private fixed capital formation"
Final_Gk        "Gross government fixed capital formation"
Final_St        "Increase in stocks"
Final_Ex        "Exports"
Final_Tot        "Total final demand"
/

set r0 region for KEI_LINKAGE Model /
China
EUR
India
Japan
Korea
LAF
MEA
OEU
OTH
SEA
USA
/;

set va(i_s) Value added/
resin
labor
dep
surplus
subsidy
PTAX
/;

set va0(va) Value added exluding subsidy/
resin
labor
dep
surplus
PTAX
/;

set va_nonre(i_s) Value added excluding residual input/
labor
dep
surplus
subsidy
PTAX
/;


set Fact(va) Factors/
labor
dep
surplus
/

set PTAXVA(I_S)/
PTAX
/

alias(fact,endw);


set fp Facteurs /
   Land       " TERRE "
   Capital    " Capital "
   Lab        " TRAVAIL (Offre) "
   NatRes     " Ressources naturelles "
   RNDsvs      "R&D Service"
/ ;



Set Fin_DD(Fin_Demand) domestic final demand /Final_PC, Final_GC, Final_Pk, Final_GK, Final_ST/;
Set Fin_DX(Fin_Demand) export demand /Final_Ex/;
Set Fin_K(Fin_Demand) Capital demand  /Final_PK, Final_GK, Final_ST/;

set i_sec0 Original Sector Classification based on the Korean 2005-year IO /
0001
0002
0003
0004
0005
0006
0007
0008
0009
0010
0011
0012
0013
0014
0015
0016
0017
0018
0019
0020
0021
0022
0023
0024
0025
0026
0027
0028
0029
0030
0031
0032
0033
0034
0035
0036
0037
0038
0039
0040
0041
0042
0043
0044
0045
0046
0047
0048
0049
0050
0051
0052
0053
0054
0055
0056
0057
0058
0059
0060
0061
0062
0063
0064
0065
0066
0067
0068
0069
0070
0071
0072
0073
0074
0075
0076
0077
0078
0079
0080
0081
0082
0083
0084
0085
0086
0087
0088
0089
0090
0091
0092
0093
0094
0095
0096
0097
0098
0099
0100
0101
0102
0103
0104
0105
0106
0107
0108
0109
0110
0111
0112
0113
0114
0115
0116
0117
0118
0119
0120
0121
0122
0123
0124
0125
0126
0127
0128
0129
0130
0131
0132
0133
0134
0135
0136
0137
0138
0139
0140
0141
0142
0143
0144
0145
0146
0147
0148
0149
0150
0151
0152
0153
0154
0155
0156
0157
0158
0159
0160
0161
0162
0163
0164
0165
0166
0167
0168
0169
0170
0171
0172
0173
0174
0175
0176
0177
0178
0179
0180
0181
0182
0183
0184
0185
0186
0187
0188
0189
0190
0191
0192
0193
0194
0195
0196
0197
0198
0199
0200
0201
0202
0203
0204
0205
0206
0207
0208
0209
0210
0211
0212
0213
0214
0215
0216
0217
0218
0219
0220
0221
0222
0223
0224
0225
0226
0227
0228
0229
0230
0231
0232
0233
0234
0235
0236
0237
0238
0239
0240
0241
0242
0243
0244
0245
0246
0247
0248
0249
0250
0251
0252
0253
0254
0255
0256
0257
0258
0259
0260
0261
0262
0263
0264
0265
0266
0267
0268
0269
0270
0271
0272
0273
0274
0275
0276
0277
0278
0279
0280
0281
0282
0283
0284
0285
0286
0287
0288
0289
0290
0291
0292
0293
0294
0295
0296
0297
0298
0299
0300
0301
0302
0303
0304
0305
0306
0307
0308
0309
0310
0311
0312
0313
0314
0315
0316
0317
0318
0319
0320
0321
0322
0323
0324
0325
0326
0327
0328
0329
0330
0331
0332
0333
0334
0335
0336
0337
0338
0339
0340
0341
0342
0343
0344
0345
0346
0347
0348
0349
0350
0351
0352
0353
0354
0355
0356
0357
0358
0359
0360
0361
0362
0363
0364
0365
0366
0367
0368
0369
0370
0371
0372
0373
0374
0375
0376
0377
0378
0379
0380
0381
0382
0383
0384

/;


alias(i_sec0,j_sec0);

set i_ene(i_sec0) Energy Sectors /
0026           "Anthracite"
0027           "Bituminous coal"
0028           "Crude petroleum"
0029           "Natural gas"
0100           "Coal briquettes"
0099           "Coke and other coal products"
0101           "Naphtha"
0102           "Gasoline"
0103           "Jet oil"
0104           "Kerosene"
0105           "Light oil"
0106           "Heavy oil"
0107           "Liquefied petroleum gas"
0108           "Refined mixture for fuel oil"
0109           "Lubricants and Grease"
0110           "Misc. petroleum refinery products"
0274           "Hydro power generation"
0275           "thermal power generation"
0276           "nuclear power generation"
0277           "self generation electricity"
0278           "New Renewable Energy"
0279           "Manufactured gas supply"
0280           "Steam and hot water supply"
/


Set Energy Energy /
E1     "Total of Coal,석탄"
E11     "Anthracite,무연탄"
E111     "Domestic,국내탄(연탄)"
E112     "Import,수입탄(무연탄)"
E12     "Bituminous,유연탄"
E121     "Coking,원료탄(기타석탄)"
E122     "Steaming,연료탄(유연탄)"
E2     "Total of Petroleum,석유"
E21     "Energy Use,에너지유"
E211     "Gasoline,휘발유"
E212     "Kerosene,등유"
E213     "Diesel,경유"
E214     "B-A,경질중유"
E215     "B-B,중유"
E216     "B-C,중질중유"
E217     "JA-1,JA-1"
E218     "JP-4,JP-4"
E219     "AVI-G,AVI-G"
E22     "LPG,LPG"
E221     "Propane,프로판"
E222     "Butane,부탄"
E23     "Non-Energy Use,비에너지"
E231     "Naphtha,나프타"
E232     "Solvent,용제"
E233     "Asphalt,아스팔트"
E234     "Lubricant,윤활기유"
E235     "Paraffin-Wax,파라핀왁스"
E236     "Petroleum Coke,석유코크"
E237     "Other Products,기타제품"
E3     "LNG,천연가스"
E4     "Town Gas,도시가스"
E5     "Hydro,수력"
E6     "Nuclear,원자력"
E7     "Electricity,전력"
E8     "Heat,열에너지"
E9     "Renewable Energy,신재생 "
E10     "Total,합계"
/

Set Energy_D     Energy Demand Category/
ED11     "Domestic Production,국내생산"
ED12     "Imports,수입"
ED121     "(Petroleum Products),  1)석유생산"
ED122     "(Petroleum Imports),  2)석유수입"
ED13     "Exports,수출"
ED14     "International Bunkers,국제벙카링"
ED15     "Stock Change,재고증감"
ED151     "Former Stock,  1)연초재고"
ED152     "Ending Stock,  2)연말재고"
ED16     "Stastical Difference,통계오차"
ED1     "Primary Consumption,1차에너지소비"
ED2     "Transformation,에너지전환"
ED21     "Electric Generation,  1)발전"
ED22     "District Heating,  2)지역난방"
ED23     "Gas Manufacturing,  3)가스제조"
ED24     "Own Use and Loss,자가소비및손실"
ED3     "Final Consumption,최종에너지소비"
ED31     "Industry,1.산업부문"
ED311     "Agriculture and Fishery,  1)농림어업"
ED312     "Mining,  2)광업"
ED313     "Manufacturing,  3)제조업"
ED3131     "Food Tobacco,      a.음식담배"
ED3132     "Textile Apparel,      b.섬유의복"
ED3133     "Wood Product,      c.목재나무"
ED3134     "Pulp Publications,      d.펄프인쇄"
ED3135     "Petroleum Chemical,      e.석유화학"
ED3136     "Non-Metalic,      f.비금속"
ED3137     "Iron Steel,      g.1차금속"
ED3138     "Non-ferrous,      h.비철금속"
ED3139     "Fabricated Metal,      i.조립금속"
ED3140     "Other Manufacturing,      j.기타제조"
ED3141     "Other Energy,      k.기타에너지"
ED314     "Construction,  4)건설업"
ED32     "Transportation,2.수송부문"
ED321     "Rail,  1)철도운수"
ED322     "Land,  2)육상운수"
ED323     "Water,  3)수상운수"
ED324     "Air,  4)항공운수"
ED33     "Residential,3.가정부문"
ED34     "Commercial,4.상업부문"
ED35     "Public,5.공공기타부문"
/;

set mapi_SEC0(i_sec0,i0) mapping between i_sec0 and i0 /
0001.Agri
0002.Agri
0003.Agri
0004.Agri
0005.Agri
0006.Agri
0007.Agri
0008.Agri
0009.Agri
0010.Agri
0011.Agri
0012.Agri
0013.Agri
0014.Agri
0015.Agri
0016.Agri
0017.Agri
0018.Agri
0019.Agri
0020.Agri
0021.Agri
0022.Agri
0023.Agri
0024.Agri
0025.Agri
0026.Mining
0027.Mining
0028.Mining
0029.Mining
0030.Mining
0031.Mining
0032.Mining
0033.Mining
0034.Mining
0035.FoodPr
0036.FoodPr
0037.FoodPr
0038.FoodPr
0039.FoodPr
0040.FoodPr
0041.FoodPr
0042.FoodPr
0043.FoodPr
0044.FoodPr
0045.FoodPr
0046.FoodPr
0047.FoodPr
0048.FoodPr
0049.FoodPr
0050.FoodPr
0051.FoodPr
0052.FoodPr
0053.FoodPr
0054.FoodPr
0055.FoodPr
0056.FoodPr
0057.FoodPr
0058.FoodPr
0059.FoodPr
0060.FoodPr
0061.FoodPr
0062.TexWear
0063.TexWear
0064.TexWear
0065.TexWear
0066.TexWear
0067.TexWear
0068.TexWear
0069.TexWear
0070.TexWear
0071.TexWear
0072.TexWear
0073.TexWear
0074.TexWear
0075.TexWear
0076.TexWear
0077.TexWear
0078.TexWear
0079.TexWear
0080.TexWear
0081.TexWear
0082.TexWear
0083.LumProd
0084.LumProd
0085.LumProd
0086.LumProd
0087.LumProd
0088.LumProd
0089.LumProd
0090.LumProd
0091.LumProd
0092.LumProd
0093.LumProd
0094.LumProd
0095.LumProd
0096.LumProd
0097.LumProd
0098.LumProd
0099.Petrol
0100.Petrol
0101.Petrol
0102.Petrol
0103.Petrol
0104.Petrol
0105.Petrol
0106.Petrol
0107.Petrol
0108.Petrol
0109.Petrol
0110.Petrol
0111.ChemPla
0112.ChemPla
0113.ChemPla
0114.ChemPla
0115.ChemPla
0116.ChemPla
0117.ChemPla
0118.ChemPla
0119.ChemPla
0120.ChemPla
0121.ChemPla
0122.ChemPla
0123.ChemPla
0124.ChemPla
0125.ChemPla
0126.ChemPla
0127.ChemPla
0128.ChemPla
0129.ChemPla
0130.ChemPla
0131.ChemPla
0132.ChemPla
0133.ChemPla
0134.ChemPla
0135.ChemPla
0136.ChemPla
0137.ChemPla
0138.ChemPla
0139.ChemPla
0140.MinMet
0141.MinMet
0142.MinMet
0143.MinMet
0144.MinMet
0145.MinMet
0146.MinMet
0147.MinMet
0148.MinMet
0149.MinMet
0150.MinMet
0151.MinMet
0152.MinMet
0153.MinMet
0154.MinMet
0155.MinMet
0156.MinMet
0157.MinMet
0158.MinMet
0159.MinMet
0160.MinMet
0161.MinMet
0162.MinMet
0163.MinMet
0164.MinMet
0165.MinMet
0166.MinMet
0167.MinMet
0168.MinMet
0169.MinMet
0170.MinMet
0171.MinMet
0172.MinMet
0173.MinMet
0174.MinMet
0175.MinMet
0176.MinMet
0177.MinMet
0178.MinMet
0179.Macheqp
0180.MinMet
0181.MinMet
0182.MinMet
0183.MinMet
0184.MinMet
0185.MinMet
0186.MinMet
0187.MinMet
0188.MinMet
0189.MinMet
0190.MinMet
0191.MinMet
0192.MinMet
0193.Macheqp
0194.Macheqp
0195.Macheqp
0196.Macheqp
0197.Macheqp
0198.Macheqp
0199.Macheqp
0200.Macheqp
0201.Macheqp
0202.Macheqp
0203.Macheqp
0204.Macheqp
0205.Macheqp
0206.Macheqp
0207.Macheqp
0208.Macheqp
0209.Macheqp
0210.Macheqp
0211.Macheqp
0212.Macheqp
0213.Macheqp
0214.Macheqp
0215.Macheqp
0216.Macheqp
0217.Macheqp
0218.Macheqp
0219.Macheqp
0220.Macheqp
0221.Macheqp
0222.Macheqp
0223.Macheqp
0224.Macheqp
0225.Macheqp
0226.Macheqp
0227.Macheqp
0228.Macheqp
0229.Macheqp
0230.Macheqp
0231.EleEqp
0232.EleEqp
0233.EleEqp
0234.EleEqp
0235.EleEqp
0236.Macheqp
0237.EleEqp
0238.EleEqp
0239.EleEqp
0240.Macheqp
0241.Macheqp
0242.Macheqp
0243.Macheqp
0244.Macheqp
0245.Macheqp
0246.Macheqp
0247.Macheqp
0248.Macheqp
0249.Vehicle
0250.Vehicle
0251.Vehicle
0252.Vehicle
0253.Vehicle
0254.Vehicle
0255.Vehicle
0256.Vehicle
0257.Vehicle
0258.Vehicle
0259.Vehicle
0260.Vehicle
0261.Vehicle
0262.Vehicle
0263.Manufac
0264.Manufac
0265.Manufac
0266.Manufac
0267.Manufac
0268.Manufac
0269.Manufac
0270.Manufac
0271.Manufac
0272.Manufac
0273.PubSer
0274.Electri
0275.Electri
0276.Electri
0277.Electri
0278.Electri
0279.GasWat
0280.GasWat
0281.GasWat
0282.PubSer
0283.PubSer
0284.PubSer
0285.PubSer
0286.PubSer
0287.Const
0288.Const
0289.Const
0290.Const
0291.Const
0292.Const
0293.Const
0294.Const
0295.Const
0296.Const
0297.Const
0298.Const
0299.Const
0300.Const
0301.Const
0302.TradSer
0303.TradSer
0304.Transp
0305.Transp
0306.Transp
0307.Transp
0308.Transp
0309.Transp
0310.Transp
0311.Transp
0312.Transp
0313.Transp
0314.Transp
0315.Transp
0316.Transp
0317.Transp
0318.TradSer
0319.TradSer
0320.TradSer
0321.TradSer
0322.TradSer
0323.TradSer
0324.BusiSer
0325.BusiSer
0326.TradSer
0327.BusiSer
0328.BusiSer
0329.BusiSer
0330.BusiSer
0331.BusiSer
0332.BusiSer
0333.BusiSer
0334.BusiSer
0335.BusiSer
0336.BusiSer
0337.BusiSer
0338.BusiSer
0339.BusiSer
0340.BusiSer
0341.BusiSer
0342.BusiSer
0343.BusiSer
0344.BusiSer
0345.BusiSer
0346.PubSer
0347.PubSer
0348.PubSer
0349.PubSer
0350.BusiSer
0351.BusiSer
0352.BusiSer
0353.BusiSer
0354.BusiSer
0355.BusiSer
0356.BusiSer
0357.BusiSer
0358.BusiSer
0359.BusiSer
0360.PubSer
0361.PubSer
0362.PubSer
0363.PubSer
0364.PubSer
0365.PubSer
0366.PubSer
0367.PubSer
0368.PubSer
0369.PubSer
0370.PubSer
0371.PubSer
0372.BusiSer
0373.BusiSer
0374.BusiSer
0375.BusiSer
0376.BusiSer
0377.BusiSer
0378.BusiSer
0379.BusiSer
0380.BusiSer
0381.BusiSer
0382.BusiSer
0383.BusiSer
0384.BusiSer
/
;
set resout /resout/
;
set resin /resin/
;
