function pass = diffexp
% Tests the computation of derivatives using DIFF  
% when the chebfuns are defined on unbounded domains.

tol = chebfunpref('eps');

f = chebfun(@(x) exp(x), [-inf,2]);
pass(1) = norm(f-diff(f),inf) < tol*5000;
pass(2) = norm(f-diff(f,2),inf) < max(1e-10, tol*1000);

f = chebfun(@(x) exp(-x.^2), [-inf,inf]);
df = chebfun(@(x) -2*x.*exp(-x.^2), [-inf,inf]);
pass(3) = norm(df-diff(f),inf) < tol*100;
