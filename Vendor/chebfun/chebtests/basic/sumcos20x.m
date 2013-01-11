function pass = sumcos20x

% Tests a couple of simple integrals, real and complex.
% (A Level 0 chebtest)
% Toby Driscoll and Rodrigo Platte.

tol = chebfunpref('eps');

f = chebfun('cos(20*x)');
pass = abs(sum(f)-sin(20)/10) < 1.5e-15*(tol/eps);

pass(2) = abs(sum(f*1i)-1i*sin(20)/10) < 1.5e-15*(tol/eps);

