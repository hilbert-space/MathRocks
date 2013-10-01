* A ring with two inverters.

.include 'include/components/inverter_cmu.sp'
.include 'include/circuits/ring.sp'
.include 'include/models/HP.sp'
.param Vdd = 1

.data dataset mer
+ file = 'parameters_T_L.txt' T = 1 L = 2
.enddata

.end
