* Input parameters
.param Leff = 22.5n

* Constants
.param Leffnom = 22.5n
.param Lnom = 50n

* Derived paramters
.param L = 'Lnom + Leff - Leffnom' $ 50n

.subckt inverter in out dd ss bn bp
M1 out in dd bp pmos
+ L   = 'L'
+ W   = 135n
+ AD  = 14.175f
+ PD  = 345n
+ NRD = 777.78m
+ AS  = 14.175f
+ PS  = 345n
+ NRS = 777.78m
M2 out in ss bn nmos
+ L   = 'L'
+ W   = 90n
+ AD  = 9.45f
+ PD  = 300n
+ NRD = 1.1667
+ AS  = 9.45f
+ PS  = 300n
+ NRS = 1.1667
.ends
