---
title: "Composite Regression for Repeated Surveys"
author: Daniel Bonnery
output: md_document
---

`CompositeRegressionEstimation` is an R package that allows to compute estimators for longitudinal survey:
* Composite Regression ["Fuller, Wayne A., and J. N. K. Rao. "A regression composite estimator with application to the Canadian Labour Force Survey." Survey Methodology 27.1 (2001): 45-52."](http://www.statcan.gc.ca/pub/12-001-x/2001001/article/5853-eng.pdf)
* Yansaneh Fuller
* AK estimator

#  General usage

## Install


```r
devtools::install_github("DanielBonnery/CompositeRegressionEstimation")
```
## Demonstration code
This package has been used for the paper submitted by D. Bonnery, P. Lahiri and Y. Cheng on real data (CPS data).
One can consult the pdf package documentation on the github page to see demo code.

Below is given a basic demonstration code on a simulated dataset

```r
library(CompositeRegressionEstimation)
data(CRE_data)
example(MR)
```

```
FALSE 
FALSE MR> MR(list.tables<-plyr::dlply(CRE_data,.variables=~time),w="Sampling.weight",list.xMR="Status",id="Identifier",list.y=c("Hobby","Status","State"))$dfEst;
FALSE MR(alpha) estimate for variable y at time t 
FALSE , , Alpha = 0.75
FALSE 
FALSE             y
FALSE t            Hobby_nShopping Hobby_nTV Status_nemployed Status_nnot_in_the_labor_force Status_nunemployed State_nAlabama State_nAlaska
FALSE   2010-01-01        108568.7  103752.3         65569.66                       69816.58           76934.76       3615.000      365.0000
FALSE   2010-01-02        111099.3  101221.7         68580.75                       70657.24           73083.00       3615.217      369.8937
FALSE   2010-01-03        104857.2  107463.8         71101.31                       71613.04           69606.64       3551.843        0.0000
FALSE   2010-01-04        104354.1  107966.9         74687.93                       67784.75           69848.32       3625.813      366.4819
FALSE   2010-01-05        105904.3  106416.7         74643.93                       67153.86           70523.21       3622.995      358.4101
FALSE   2010-01-06        106678.8  105642.2         69759.90                       72294.50           70266.60       3615.447      366.2497
FALSE   2010-01-07        103107.6  109213.4         78475.57                       65968.83           67876.60       3598.637        0.0000
FALSE   2010-01-08        100262.4  112058.6         71786.35                       74421.17           66113.48       3628.498        0.0000
FALSE   2010-01-09        107752.7  104568.3         68939.75                       74639.15           68742.10       3632.668      368.6925
FALSE   2010-01-10        110544.6  101776.4         68912.65                       75444.06           67964.30       3534.822      369.7600
FALSE   2010-01-11        100416.6  111904.4         65179.69                       77013.29           70128.02       3666.095      369.6850
FALSE             y
FALSE t            State_nArizona State_nArkansas State_nCalifornia State_nColorado State_nConnecticut State_nDelaware State_nFlorida
FALSE   2010-01-01       2212.000        2110.000          21198.00        2541.000           3100.000        579.0000       8277.000
FALSE   2010-01-02       2220.703        2129.751          21340.71        2555.359           3120.763        584.0299       8335.426
FALSE   2010-01-03       2242.540        2121.802          21303.85        2537.856           3125.502        579.8951       8236.200
FALSE   2010-01-04       2228.205        2113.050          21272.99        2549.082           3107.199          0.0000       8319.340
FALSE   2010-01-05       2217.416        2096.616          21268.23        2579.621           3107.445        583.4239       8269.925
FALSE   2010-01-06       2190.181        2118.068          21240.25        2530.608           3047.628        569.9750       8366.035
FALSE   2010-01-07       2232.669        2114.160          21309.82        2574.940           3142.806        551.6720       8267.402
FALSE   2010-01-08       2208.309        2118.364          21272.12        2546.281           3105.223        581.1892       8278.398
FALSE   2010-01-09       2231.135        2137.008          21310.90        2538.125           3097.910        570.0364       8208.875
FALSE   2010-01-10       2213.858        2078.203          21262.11        2499.297           3043.816        556.9363       8253.765
FALSE   2010-01-11       2228.185        2113.124          21378.84        2550.260           3136.738        585.9732       8279.403
FALSE             y
FALSE t            State_nGeorgia State_nHawaii State_nIdaho State_nIllinois State_nIndiana State_nIowa State_nKansas State_nKentucky
FALSE   2010-01-01       4931.000      868.0000     813.0000        11197.00       5313.000    2861.000      2280.000        3387.000
FALSE   2010-01-02       4968.315      878.5548     823.4241        11264.94       5319.426    2873.453      2297.053        3405.931
FALSE   2010-01-03       4909.811      869.2947     835.1339        11245.00       5257.093    2861.618      2298.259        3352.403
FALSE   2010-01-04       4953.696      877.0280     814.8241        11263.29       5347.776    2881.588      2279.052        3411.078
FALSE   2010-01-05       5007.850      877.8595     806.3032        11156.69       5329.838    2856.965      2304.286        3364.755
FALSE   2010-01-06       4935.072      859.6271     806.9311        11173.28       5330.857    2822.872      2273.784        3423.655
FALSE   2010-01-07       4904.598      873.7352     823.9966        11073.61       5289.996    2925.624      2255.864        3442.165
FALSE   2010-01-08       4937.464      877.3348     818.0598        11259.17       5336.239    2881.367      2291.377        3425.019
FALSE   2010-01-09       4933.936      877.1102     824.8149        11145.39       5320.104    2851.617      2303.225        3386.049
FALSE   2010-01-10       4975.791      874.5202       0.0000        11266.87       5504.978    2855.300      2343.844        3405.231
FALSE   2010-01-11       4979.054      859.0238       0.0000        11270.18       5322.951    2878.314      2287.900        3407.289
FALSE             y
FALSE t            State_nLouisiana State_nMaine State_nMaryland State_nMassachusetts State_nMichigan State_nMinnesota State_nMississippi
FALSE   2010-01-01         3806.000     1058.000        4122.000             5814.000        9111.000         3921.000           2341.000
FALSE   2010-01-02         3825.011     1067.026        4148.201             5860.645        9179.402         3954.784           2358.197
FALSE   2010-01-03         3830.800     1083.400        4067.004             5834.831        9177.900         3934.026           2339.094
FALSE   2010-01-04         3808.814     1066.337        4125.949             5835.170        9183.439         3943.600           2348.049
FALSE   2010-01-05         3813.617     1039.791        4128.813             5799.108        9178.861         3941.883           2337.786
FALSE   2010-01-06         3882.975     1030.062        4031.071             5803.162        9116.386         3999.606           2395.140
FALSE   2010-01-07         3815.644     1096.732        4166.413             5812.695        9097.337         3972.326           2269.662
FALSE   2010-01-08         3835.132     1074.874        4147.892             5832.323        9149.287         3929.491           2359.807
FALSE   2010-01-09         3803.778     1039.382        4101.126             5775.341        9150.007         3934.632           2335.209
FALSE   2010-01-10         3841.689     1105.034        4046.764             6006.397        9238.839         3935.133           2318.537
FALSE   2010-01-11         3849.767     1068.413        4181.316             5854.430        9190.789         3927.572           2367.522
FALSE             y
FALSE t            State_nMissouri State_nMontana State_nNebraska State_nNevada State_nNew_Hampshire State_nNew_Jersey State_nNew_Mexico
FALSE   2010-01-01        4767.000       746.0000        1544.000      590.0000             812.0000          7333.000          1144.000
FALSE   2010-01-02        4800.332       745.4074        1549.009      595.7547             818.9329          7376.771          1147.381
FALSE   2010-01-03        4775.070       750.7303        1561.332      567.0621             822.3144          7337.854          1155.517
FALSE   2010-01-04        4781.694       748.9592        1555.572      585.7327             817.4486          7347.542          1155.776
FALSE   2010-01-05        4783.677         0.0000        1539.417      585.5678             804.7331          7398.411          1120.813
FALSE   2010-01-06        4835.620       749.1548        1552.045      608.2301             778.5988          7349.837          1207.891
FALSE   2010-01-07        4777.460       726.3867        1507.739      581.8992             817.9194          7390.273          1152.224
FALSE   2010-01-08        4802.504       746.8952        1540.532      582.4838             806.7606          7352.551          1151.651
FALSE   2010-01-09        4804.405       749.3666        1554.310      577.0631             815.8563          7387.683          1133.700
FALSE   2010-01-10        4944.285       731.0666        1600.944      553.9068             893.6494          7489.467          1061.994
FALSE   2010-01-11        4816.132         0.0000        1545.932      597.4423             815.3842          7416.140          1153.014
FALSE             y
FALSE t            State_nNew_York State_nNorth_Carolina State_nNorth_Dakota State_nOhio State_nOklahoma State_nOregon State_nPennsylvania
FALSE   2010-01-01        18076.00              5441.000            637.0000    10735.00        2715.000      2284.000            11860.00
FALSE   2010-01-02        18168.07              5475.369            645.5404    10796.98        2728.760      2293.139            11936.47
FALSE   2010-01-03        18050.74              5504.799            643.5334    10763.45        2733.235      2245.283            11880.77
FALSE   2010-01-04        18137.39              5445.967            638.9142    10751.56        2720.522      2286.646            11939.23
FALSE   2010-01-05        18190.88              5458.096            642.4302    10807.21        2726.420      2318.975            11906.34
FALSE   2010-01-06        18093.49              5470.814            644.0518    10746.26        2759.125      2265.071            11861.51
FALSE   2010-01-07        18038.13              5486.729            665.6758    10653.97        2704.990      2269.289            11942.78
FALSE   2010-01-08        18199.66              5466.914            631.4975    10775.57        2699.205      2278.010            11841.13
FALSE   2010-01-09        18136.79              5472.758            650.0073    10777.51        2698.251      2279.712            11938.43
FALSE   2010-01-10        17538.27              5401.344            646.1436    10886.58        2726.536      2400.996            12095.59
FALSE   2010-01-11        18209.06              5504.795            628.9953    10863.40        2709.174      2297.666            11929.02
FALSE             y
FALSE t            State_nRhode_Island State_nSouth_Carolina State_nSouth_Dakota State_nTennessee State_nTexas State_nUtah State_nVermont
FALSE   2010-01-01            931.0000              2816.000            681.0000         4173.000     12237.00    1203.000       472.0000
FALSE   2010-01-02              0.0000              2825.265            683.5308         4189.437     12329.80    1210.907       474.6613
FALSE   2010-01-03            928.0063              2810.353            663.4173         4202.850     12261.74    1206.914       489.8410
FALSE   2010-01-04            942.5810              2842.299            679.4650         4192.230     12303.71    1212.132       478.0741
FALSE   2010-01-05            921.8079              2802.226            675.5873         4181.911     12298.13    1212.434       474.7705
FALSE   2010-01-06            922.3020              2851.569            688.9625         4169.614     12216.46    1162.186       470.9580
FALSE   2010-01-07            953.3242              2848.137            654.5836         4208.136     12324.29    1206.544       477.3479
FALSE   2010-01-08            936.2054              2825.725            698.5964         4188.419     12232.36    1203.551       480.5085
FALSE   2010-01-09            932.7335              2812.623            680.6764         4203.686     12299.36    1194.819         0.0000
FALSE   2010-01-10            886.0461              2812.984            704.4438         4153.293     12185.97    1198.430       529.5362
FALSE   2010-01-11            953.0354              2806.984            682.7420         4205.578     12331.94    1202.057       487.4472
FALSE             y
FALSE t            State_nVirginia State_nWashington State_nWest_Virginia State_nWisconsin State_nWyoming
FALSE   2010-01-01        4981.000          3559.000             1799.000         4589.000       376.0000
FALSE   2010-01-02        5017.763          3586.873             1806.939         4621.689         0.0000
FALSE   2010-01-03        4992.501          3583.844             1804.986         4612.442       377.2604
FALSE   2010-01-04        5000.650          3605.937             1817.527         4611.584         0.0000
FALSE   2010-01-05        5023.363          3610.943             1805.413         4611.458       371.5108
FALSE   2010-01-06        4967.300          3620.501             1761.506         4639.040         0.0000
FALSE   2010-01-07        5032.575          3531.389             1797.895         4593.215       365.5958
FALSE   2010-01-08        5004.653          3574.478             1809.755         4598.164         0.0000
FALSE   2010-01-09        5022.518          3539.231             1792.433         4617.384       372.6148
FALSE   2010-01-10        5027.927          3549.164             1848.406         4516.892       405.6285
FALSE   2010-01-11        4996.409          3566.784             1847.107         4617.038       384.8994
FALSE 
FALSE , , Alpha = 01
FALSE 
FALSE             y
FALSE t            Hobby_nShopping Hobby_nTV Status_nemployed Status_nnot_in_the_labor_force Status_nunemployed State_nAlabama State_nAlaska
FALSE   2010-01-01       108568.71 103752.29         65569.66                       69816.58           76934.76      3615.0000     365.00000
FALSE   2010-01-02       112053.62 100267.38         61047.29                       77264.36           74009.35      2727.5952      16.93916
FALSE   2010-01-03       110244.31 102076.69         64589.30                       67612.08           80119.62      3242.4017       0.00000
FALSE   2010-01-04       111614.75 100706.25         74174.34                       61402.89           76743.77      2295.4277    1436.83484
FALSE   2010-01-05       113334.82  98986.18         72318.55                       69352.56           70649.89       112.4652     -35.22311
FALSE   2010-01-06       107518.02 104802.98         66819.37                       86245.75           59255.88      7141.5568      37.12328
FALSE   2010-01-07        94978.59 117342.41         77866.97                       61841.25           72612.78      2985.7996       0.00000
FALSE             y
FALSE t            State_nArizona State_nArkansas State_nCalifornia State_nColorado State_nConnecticut State_nDelaware State_nFlorida
FALSE   2010-01-01     2212.00000      2110.00000          21198.00      2541.00000          3100.0000      579.000000       8277.000
FALSE   2010-01-02      -44.76473        50.66718          26895.30      2715.41634          2499.7286       15.089785       9482.186
FALSE   2010-01-03      -43.77013      2206.53905          32807.60      -139.82121          1405.3088       75.683334       9287.584
FALSE   2010-01-04     1518.21241      1203.91343          18574.56        29.07170          3117.1102        0.000000       7019.807
FALSE   2010-01-05     2604.37292      2713.71663          21365.94        56.54249          1606.4746     1139.339667       7633.697
FALSE   2010-01-06     4354.94722      3726.79759          21459.19      2055.26644           980.0739       -5.788024      12881.034
FALSE   2010-01-07      -63.43799      2125.98863          14070.59      2278.24678          3471.1149      177.367411       6878.476
FALSE             y
FALSE t            State_nGeorgia State_nHawaii State_nIdaho State_nIllinois State_nIndiana State_nIowa State_nKansas State_nKentucky
FALSE   2010-01-01       4931.000    868.000000   813.000000       11197.000       5313.000    2861.000    2280.00000        3387.000
FALSE   2010-01-02       2701.637    628.817077  1687.494098       13985.854       4042.668    2677.855    1557.09655        4091.111
FALSE   2010-01-03       3355.306   2368.357591   -14.555267       18265.100       7563.621    1214.225      51.86955        4854.497
FALSE   2010-01-04       6139.893    -41.710279  1681.599072        7051.603       5266.271    2461.720     -81.05327        5479.132
FALSE   2010-01-05       4169.506    -41.454520    -3.374166       11124.541       5631.943    2610.842    1837.07491        2407.049
FALSE   2010-01-06       4059.337    432.151131  1066.373098       11873.424       2214.942    3280.485    2630.44793        4132.818
FALSE   2010-01-07       8049.581   2036.527821   804.635159       16020.312       5412.173    2277.614    2507.88634        4346.190
FALSE             y
FALSE t            State_nLouisiana State_nMaine State_nMaryland State_nMassachusetts State_nMichigan State_nMinnesota State_nMississippi
FALSE   2010-01-01         3806.000   1058.00000        4122.000             5814.000        9111.000         3921.000          2341.0000
FALSE   2010-01-02         8937.221   3220.04283        4170.124             6341.809        9591.369         1831.449          1364.7597
FALSE   2010-01-03         2204.792   1115.61108        4061.451             3107.179        6740.776         4246.595          1228.4271
FALSE   2010-01-04         2833.911   2129.04816        5571.591             9088.610       11528.160         4481.711          6358.1938
FALSE   2010-01-05         2247.056     62.37475        8393.269             6942.119        8140.589         5835.044          4723.9222
FALSE   2010-01-06         3723.780    501.07096        4673.858             6569.117        9398.777         5930.008          1172.6587
FALSE   2010-01-07         6854.458   -134.59873        2391.641            10028.507       12344.758         7989.670           390.3634
FALSE             y
FALSE t            State_nMissouri State_nMontana State_nNebraska State_nNevada State_nNew_Hampshire State_nNew_Jersey State_nNew_Mexico
FALSE   2010-01-01        4767.000      746.00000      1544.00000     590.00000           812.000000          7333.000        1144.00000
FALSE   2010-01-02        8779.486      -48.19895       -49.42678    1216.37352           953.382081          4343.540         734.76639
FALSE   2010-01-03        4640.097     3102.86433      3947.79666     -55.25733             1.478089         12303.120        1141.26179
FALSE   2010-01-04        5408.207     1437.64341      2882.11644     -15.90079          1034.846055          7172.945        1599.50601
FALSE   2010-01-05        5709.495        0.00000      2327.00452     -64.53663           795.216003          9772.111         -17.79213
FALSE   2010-01-06        2806.933       20.28791      2547.34530      66.54532          -172.282497          5863.546         165.46855
FALSE   2010-01-07        4563.422     1689.16059       200.40930      25.23123            26.711102          9441.581        3513.03886
FALSE             y
FALSE t            State_nNew_York State_nNorth_Carolina State_nNorth_Dakota State_nOhio State_nOklahoma State_nOregon State_nPennsylvania
FALSE   2010-01-01       18076.000              5441.000          637.000000   10735.000      2715.00000    2284.00000           11860.000
FALSE   2010-01-02       19134.279              4009.796           29.562315   13301.765      2165.58947     -49.07262           15687.607
FALSE   2010-01-03       13346.816              5165.075         1938.877547   11606.695      1050.56493    1293.47109            9037.692
FALSE   2010-01-04       18183.556              6201.662         1493.104704   11290.730      3029.95134    2926.88943           12726.115
FALSE   2010-01-05       16040.813              3779.387            3.312547   13768.286        75.75592    3669.91675           13987.465
FALSE   2010-01-06       22905.155              4597.851           -1.514337    8577.874      3098.98504    1239.24628            6532.841
FALSE   2010-01-07       16486.782              4299.336          -84.182511    9885.192      4511.90560    2045.85455           13199.390
FALSE             y
FALSE t            State_nRhode_Island State_nSouth_Carolina State_nSouth_Dakota State_nTennessee State_nTexas  State_nUtah State_nVermont
FALSE   2010-01-01           931.00000             2816.0000          681.000000         4173.000    12237.000 1203.0000000      472.00000
FALSE   2010-01-02             0.00000             6244.5650          -20.068259         4984.612     7015.695    9.0845749      950.73993
FALSE   2010-01-03            60.29114             2569.1275          911.288000         3245.979     8340.246    0.3762575      -38.51339
FALSE   2010-01-04           -11.41790             2367.6165           -5.122711         2380.548    13262.251  -25.9587481     1920.83130
FALSE   2010-01-05           -13.91238             2481.0388         2753.350947         4452.050     9613.659  680.3687826      957.44411
FALSE   2010-01-06          1900.83356              169.4286          490.889395         5497.154    14561.464 1037.4433973     1919.02257
FALSE   2010-01-07          -144.42138             -222.9491          205.252967         2247.086    12239.103 2350.5764172     -101.89052
FALSE             y
FALSE t            State_nVirginia State_nWashington State_nWest_Virginia State_nWisconsin State_nWyoming
FALSE   2010-01-01       4981.0000        3559.00000            1799.0000        4589.0000      376.00000
FALSE   2010-01-02       2914.5891          43.04364            2883.7727        5898.0519        0.00000
FALSE   2010-01-03       6340.8908        2106.41766            1909.2777        8151.3533      998.93707
FALSE   2010-01-04       2965.0339        1619.28934            2372.4894        4960.4554        0.00000
FALSE   2010-01-05       8145.5964        5030.02079            1775.0461        5302.3315       19.74531
FALSE   2010-01-06       3207.9362        6607.42226             947.1672        3444.5075        0.00000
FALSE   2010-01-07       -454.1613        5398.87126            3087.8815        4605.8792       62.07979
```

## Manual
R package pdf manual can be found there:
["CompositeRegressionEstimation.pdf"](https://github.com/DanielBonnery/CompositeRegressionEstimation/blob/master/CompositeRegressionEstimation.pdf)

# Repeated surveys

### An example: the US Census Burea CPS survey.
The R package `dataCPS` available there: ["github.com/DanielBonnery/dataCPS"](github.com/DanielBonnery/dataCPS) contains functions to download the CPS anonymised micro data from the Census Website.

The output of a repeated survey is in general a sequence of datasets, 
one dataset for each iteration of the survey. Each dataset may contain variables that can be described by the same dictionnary, or there may be changes. The sampling units also usually differ from one dataset to the other, due to non response or due to a deliberate choice not to sample the same units.
Some repeated surveys use rotation groups and a rotation pattern.

Let $m\in\{1,\ldots,M\}$ be an index of the time, and let $S_m$ be the set of sampling units at time $m$. The samples $S_m$ are subsets of a larger population $U$.

For each unit $k$ in $S_m$, usually the dataset contains:
the values $Y_{m,k}$ of a variable of interest $Y$ for unit $k$ and the period $m$.
It also contains $w_{m,k}$ a sampling weight.


## Estimation 

The output of a survey are often used to produce estimators of totals over the population of certain characteritics, or function of this same totals, 
in a fixed population model for design-based inference.  

### Linear estimates

#### Direct estimate

The direct estimator of the total is $\sum_{k\in S_m} w_{k,m} Y_{k,m}$.


```r
period<-200501:200512
Direct.est<-CompositeRegressionEstimation::WS(lapply(data(list=paste0("cps",period),package="dataCPS"),get),weight="pwsswgt",list.y = "pemlr")
Direct.emp.rate<-with(as.data.frame(Direct.est),(pemlr_n1 +pemlr_n2)/(pemlr_n1 +pemlr_n2+ pemlr_n3 +pemlr_n4))
library(ggplot2);ggplot(data=data.frame(period=period,E=Direct.emp.rate),aes(x=period,y=E))+geom_line()
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-1-1.png)

#### Month in sample estimate

#### AK estimator

```
CompositeRegressionEstimation::CPS_AK()
```


#### Rough estimation of the month-in-sample estimate covariance matrix

#### Empirical best AK estimator

#### Empirical best YF estimator

#### Empirical best linear estimator

### Modified regression (Singh, Fuller-Rao)


