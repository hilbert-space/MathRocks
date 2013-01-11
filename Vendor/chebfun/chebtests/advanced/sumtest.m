function pass = sumtest

% Tests various integrals over unbounded domains.
% Rodrigo Platte, May 2009

% (A Level 1 chebtest)

tol = chebfunpref('eps');
mappref('adaptinf',1,'parinf',[1 0])

% Exponential decay

f = chebfun(@(x) exp(-x), [0 inf]);
pass(1) = abs(sum(f)-1)<tol*100;

f = chebfun(@(x) exp(-0.001*x), [0 inf]);
pass(2) = abs(sum(f)-1000)<tol*5e4;

f = chebfun(@(x) exp(-1000*x), [0 inf]);
pass(3) = abs(sum(f)-0.001)<tol*.1;

f = chebfun(@(x) exp(-x.^2),[-inf inf]);
pass(4) = abs(sum(f)-sqrt(pi))<tol*10;

f = chebfun(@(x) exp(-(100*x).^2),[-inf inf]);
pass(5) = abs(sum(f)-sqrt(pi)/100)<tol;

f = chebfun(@(x) sin(10*x).*exp(-x), [0 inf]);
pass(6) = abs(sum(f) - 990/9999)<tol*500;

% Algebraic decay

f = chebfun(@(x) 1./x.^2, [1 inf]);
pass(7) = abs(sum(f) - 1)< max(1e-5,tol*10);

f = chebfun(@(x) 1./x.^3, [-inf -1]);
pass(8) = abs(sum(f) + 0.5) < tol*1e5;

f = chebfun(@(x) 1./(1+0.01*x.^2), [ -inf,inf]);
pass(9) = abs(sum(f) -pi*10) < max(2e-5, tol*10);

mappref('adaptinf',0);


