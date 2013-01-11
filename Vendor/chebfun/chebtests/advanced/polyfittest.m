function pass = polyfittest
% This test checks that the polyfit commmandis working correctly.
% Rodrigo Platte Jan 2009


tol = 100*chebfunpref('eps');

x = chebfun('x',[-2 2]);
g = sign(x);
f0 = polyfit(g, 0);
pass(1) = norm(f0,inf) < tol;
f1 = polyfit(g, 1);
pass(2) = norm(f1 - chebfun([-1.5 1.5],[-2 2]) ,inf) < tol;
f2 = polyfit(g, 2);
pass(3) = norm(f2 - chebfun([-1.5 1.5],[-2 2]) ,inf) < tol;
f3 = polyfit(g, 3);
pass(4) = norm(f3 - chebfun([-.625 -1.1328125 1.1328125 .625],[-2 2]) ,inf) < tol;
