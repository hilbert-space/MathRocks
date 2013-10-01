.param L = 50n

.param Lnom = 50n
.param Wp = '1.67 * 8 * Lnom'
.param Wn = '8 * Lnom'
.param Lambda = '0.5 * Lnom'

.subckt inverter in out dd ss bn bp
M1 out in dd bp pmos
+ L  = 'L'
+ W  = 'Wp'
+ AS = '5 * Wp * Lambda'
+ AD = '5 * Wp * Lambda'
+ PS = '2 * Wp + 10 * Lambda'
+ PD = '2 * Wp + 10 * Lambda'
M2 out in ss bn nmos
+ L  = 'L'
+ W  = 'Wn'
+ AS = '5 * Wn * Lambda'
+ AD = '5 * Wn * Lambda'
+ PS = '2 * Wn + 10 * Lambda'
+ PD = '2 * Wn + 10 * Lambda'
.ends
