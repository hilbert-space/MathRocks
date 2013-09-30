* Ring with two Nangate inverters

.include 'include/components/inverter_nangate.sp'

X1 bp bn in dd ss int INV_X1
X2 bp bn int dd ss in INV_X1

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
