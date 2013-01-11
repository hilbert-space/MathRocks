function pass = restrict_roots

% Test restriction from one interval to another with { }.
% Rodrigo Platte, May 2009.
% A Level 0 chebtest.

tol = chebfunpref('eps');

f1 = chebfun(@(x) besselj(0,x).*exp(-.1*x),[-1 inf]);
f2 = chebfun(@(x) besselj(0,x).*exp(-.1*x),[0 30]);
f3 = f1{0,30};

pass(1) = norm(f2-f3,inf) < tol*f1.scl*100;

r1 = roots(f1);
r2 = roots(f2);

pass(2) = norm(r1(1:length(r2))-r2) < tol*f1.scl*1e4;
