function pass = aliasing
% Tests for aliasing: Check if the constructor accurately re-constructs the
% 50th Chebyshev polynomial and a highly oscillating funciton.
%
% Rodrigo Platte, May 2009.

p1 = chebfun(@(x) cos(50*acos(x)), 'sampletest', 1);
p2 = chebpoly(50,[-1,1]);
pass(1) = norm(p1-p2) < chebfunpref('eps')*100;

ff = @(x) sin(50*x).*exp(-x.^2);
f = chebfun(ff, [-10,10],'sampletest',1);
xx = linspace(-10,10,100);
pass(2) = norm(f(xx) - ff(xx),inf) < 1e3*chebfunpref('eps');

