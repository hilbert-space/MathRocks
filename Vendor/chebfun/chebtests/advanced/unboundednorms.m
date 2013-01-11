function pass = unboundednorms
% Tests norm for unbounded domains and subtraction of chebfuns.  
% Sheehan Olver, November 2009.

tol = 100*chebfunpref('eps');

r = @(v) v(2:length(v));
f = chebfun('sech(x)',[0,inf]);
f2 = chebfun(chebpolyval(r(chebpoly(f))),[0,inf]);

f3 = f - f2;

pass(1) = norm(f)-norm(f2) < tol;
pass(2) = norm(f3.vals) < tol;
pass(3) = norm(f3) < tol;
pass(4) = norm(f3,inf) < tol;


