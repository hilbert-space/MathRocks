X1 in int dd ss bn bp inverter
X2 int in dd ss bn bp inverter

Vdd dd 0 'Vdd'
Vbp bp 0 'Vdd'
Vbn bn 0 0
Vss ss 0 0

.dc data = dataset
.temp 'T'

.ic V(in) = 0
.ic V(int) = 'Vdd'
.options post = 1

.probe dc Ileak = par('abs(I(Vdd)) / 2')