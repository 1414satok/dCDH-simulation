# deChaisemartin-2020

## 概要
　de Chaisemartin and D'Haultf\[oe\]uille (2020)に関するシミュレーションを行う。Baker (2022)をベースにデータを生成し、de Chaisemartin and D'Haultf\[oe\]uilleの手法（以下、dCDH）による推定値をTwo-way fixed effectモデル（以下、TWFE）と比較する。  
　Baker (2022)は1989年から2007年までの36年間における米国1000社のROA (Return on Asset)を用いるという設定でデータのシミュレーションを行った。元論文ではStaggered DiDを仮定し、1989年、1998年、2007年に1/3ずつのサンプルに処置を施すという状況を想定していた。今回はサンプルを4分割して、「1989年に処置を受けるが、1998年以降処置を打ち止める」というグループを追加する。  
　ROAの生成過程については、Baker (2022)のsimulation3\~6を参照する。すべてのシミュレーションで共通するのが企業固定効果と時間固定効果、誤差項で、それぞれ $N(0,0.5^2)$に従う。ここに処置を受けている期間のみ、処置効果を加える。処置効果の取り方は各シミュレーションによって異なる。Simulatin3では、処置効果が常に $N(0,0.2^{2})$に従う。  
　Simulation4では処置効果がグループによって異なり、1989年に処置を受ける企業の処置効果は $N(5,0.2^2)$に従う。1998年、2007年に処置を受けるグループはそれぞれ $N(3,0.5^2)$と $N(1,0.2^2)$に従う。  
　Simulation5では処置効果が時間によって異なる。処置を受けた期間を $t$としたとき、処置効果は $\delta_{i}\sim N(0.2,0.2^2)$に従う $\delta_{i}$に対して $\tau_{it}=t\delta_{i}$をとる。例えば、1989年に処置を受け始めた企業の1993年における処置効果は $N(0.2,0.2^2)$に従う確率変数に5を掛けた値となる。
　Simulation6では処置効果がグループと時間の両方によって異なることを想定し、Simulation5における$\delta_{i}$の分布が処置を受け始める年によって、1989年のグループは $N(0.5,0.2^2)$、1998年のグループは $N(0.3,0.2^2)$、2007年のグループは $N(0.1,0.2^2)$にそれぞれ従うとする。  
　これをもとに1回のシミュレーションでROAの推移を示したのが下のグラフである。Case1\~4はそれぞれBaker (2022)のSimulation3\~6に対応する。
![fig1](https://github.com/1414ponnponn/dCDH-simulation/assets/103186935/eedc427d-c447-4bc3-b4ea-20b3d24c2fb5)

　このようなデータに対してdCDH推定量を推定し、TWFE推定量との違いやその正確性を見る。

## 結果
　データの生成を500回行い、その処置群に対する平均処置効果（ATT）を推定する。シミュレーションの結果は以下の通り。
![fig2](https://github.com/1414ponnponn/dCDH-simulation/assets/103186935/0d424321-7ac7-4631-a962-329655c73330)

　オレンジがdCDH、青がTWFEを示し、縦線はそれぞれ推定された500のATTの平均を表す。また、黒い縦線は片方が0、もう片方が処置効果の真値を表す。結果として、dCDHは処置効果を正確に推定し、特にCase3と4ではTWFEの推定が正負を違えて誤っていることが分かった。  
　以上の推定値は処置が切り替わった直後におけるATTの推定を表すが、次のグラフはその前後の処置効果を合わせて比較する。
 ![fig3](https://github.com/1414ponnponn/dCDH-simulation/assets/103186935/cebb586a-3b07-4694-91fd-d3160925ef21)

  各点と縦の線はそれぞれ推定値とその95％信頼区間である。標準誤差の計算にあたっては20回にわたってブートストラップを行った。オレンジの線は処置効果、並びに処置前のトレンドの真値を表す。左はTWFEの推定量の推移であり、やはり正確に推定できていないことが示唆される。一方で右のdCDHによる推定ではおおむね真値通りであるものの、全体的に過小評価しがちであること、いくつかの時点において真値が信頼区間に含まれていないことが見て取れる。


de Chaisemartin, C., and D'Haultf\[oe\]uille, X. 2020. Difference-in-differences with multiple time periods, Jornal of Econometrics,  225(2), 200-230.
Baker, A. C., Larcker, D. F., &amp; Wang, C. C. Y. (2022). How much should we trust staggered difference-in-differences estimates? Journal of Financial Economics, 144(2), 370–395. 
