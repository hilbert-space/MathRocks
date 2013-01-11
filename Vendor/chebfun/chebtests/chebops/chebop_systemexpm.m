function pass = chebop_systemexpm
% Exponential test, inspired by Maxwell's equation
% (A Level 3 Chebtest)
% Toby Driscoll

d = domain(-1,1);
dt = 0.6;
sigma = 0.75;  % Conductive attenuation

d = [-1 1];
A = chebop(@(x,u,v) [-sigma*u + diff(v), diff(u)], d);
A.lbc = @(u,v) u;
A.rbc = @(u,v) u;

x = chebfun('x',d);
f = exp(-20*x.^2) .* sin(30*x);
EH = [ f -f ];

B = dt*A; 
B.lbc = A.lbc;
B.rbc = A.rbc;
u = expm(B)*EH;

ucorrect = [
  -0.003493712804296   0.003507424266860
   0.017400438776808  -0.017569666673771
  -0.053993725617065   0.055047201484183
   0.098797781796113  -0.102583796707936
  -0.089121824015245   0.097254823360030
  -0.004069253343800  -0.006433053771176
   0.095392325253247  -0.087321637402261
  -0.101288249878077   0.098387426546698
   0.051307419712737  -0.057244515064558
];

pass = norm(u(0.1:0.1:0.9,:)-ucorrect,inf) < 1e4*chebfunpref('eps');
