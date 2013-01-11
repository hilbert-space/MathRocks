function pass = chebop_ivp
% This tests solves a linear IVP using chebop and checks
% that the computed solution is accurate.

tol = chebfunpref('eps');

d = [-1,1];
x = chebfun(@(x) x,d);
A = chebop(@(u) diff(u)-u,d);
A.lbc = exp(-1)-1;
u = A\(1-x);
pass = norm( u - (exp(x)+x) ) < 100*tol;
