function pass = exps_sum
% Tests SUM for Chebfuns with exponents
% Nick Hale, Nov 2009

tol = chebfunpref('eps');

f = chebfun('1./sqrt(1-x.^2)','exps',[-.5 -.5]);
pass(1) = norm(sum(f)-pi,inf) < 500*tol;

f = chebfun('feval(chebpoly(3),x).^2./sqrt(1-x.^2)','exps',[-.5 -.5]);
pass(2) = norm(sum(f)-pi/2,inf) < 500*tol;



