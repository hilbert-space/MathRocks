* Ring with two CMU inverters

.include 'include/components/inverter_cmu.sp'

X1 in int dd ss bn bp inverter
X2 int in dd ss bn bp inverter

Vdd dd 0 1
Vbp bp 0 1
Vbn bn 0 0
Vss ss 0 0

.dc data = dataset
.data dataset mer
+ file = 'T_L.txt' temp = 1 L = 2
.enddata

.ic V(in) = 0
.ic V(int) = 1
.options post = 1

.probe dc Ileak = par('abs(I(Vdd)) / 2')

.end
