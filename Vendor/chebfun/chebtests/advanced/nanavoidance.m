function pass = nanavoidance

% This test check that NaNs are avoided on point evaluations 
% by extrapolation
% Nick Hale, Nov 2009

tol = chebfunpref('eps');

f = chebfun(@(x) x./sin(x));
pass(1) = norm(f(0) - 1,inf) < tol*5000;

f = chebfun(@(x) sin(x)./x);
pass(2) = norm(f(0) - 1,inf) < tol*5000;

f = chebfun(@(x) x./sin(x),[0 1]);
pass(3) = norm(f(0) - 1,inf) < tol*5000;

f = chebfun(@(x) x./sin(x),[-1 0]);
pass(4) = norm(f(0) - 1,inf) < tol*5000;

f = chebfun(@(x) sin(x)./x./(1+x.^10),[-inf 0]);
pass(5) = norm(f(0) - 1,inf) < tol*5000;

f = chebfun(@(x) sin(x)./x./(1+x.^10),[0 inf]);
pass(6) = norm(f(0) - 1,inf) < tol*5000;

f = chebfun(@(x) sin(x)./x./(1+x.^10),[-inf inf]);
pass(7) = norm(f(0) - 1,inf) < tol*5000;



