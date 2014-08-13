* A ring with two inverters

.include 'include/components/inverter_nangate.sp'
.include 'include/circuits/ring.sp'
.include 'include/models/HP.sp'
.param Vdd = 1

.data dataset mer
+ file = 'ring_nangate_HP_T_Leff.param' T = 1 Leff = 2
.enddata

.end
