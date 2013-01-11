function pass = exps_cumsum
% Tests cumsum with exponents
% Nick Hale, Nov 2009

tol = chebfunpref('eps');

f = chebfun('1./sqrt(x)',[0 1],'exps',[-.5 -0]);
g = chebfun('2*sqrt(x)',[0 1],'exps',[.5 0]);

pass = norm(cumsum(f)-g,inf) < 500*tol;


