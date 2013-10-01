* A ring with two inverters.

.include 'include/components/inverter_nangate.sp'
.include 'include/circuits/ring.sp'
.include 'include/models/VTL.sp'
.param Vdd = 1

.data dataset mer
+ file = 'parameters_T_L_Tox.txt' T = 1 L = 2 Tox = 3
.enddata

.end
