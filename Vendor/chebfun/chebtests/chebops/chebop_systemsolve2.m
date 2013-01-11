function pass = chebop_systemsolve2

% Test solution of a 2x2 system
% (A Level 3 Chebtest)
% Toby Driscoll

tol = 2e4*chebfunpref('eps');

d = [-1 1];
A = chebop(@(x,u,v) [diff(u) + u + 2*v, diff(u) - u + diff(v)], d);
A.lbc = @(u,v) u+diff(u);
A.rbc = @(u,v) diff(v);
x = chebfun('x',d);
f = [ exp(x) chebfun(1,d) ];
u = A\f;

u1 = u(:,1); u2 = u(:,2);
pass(1) = norm( diff(u1)+u1+2*u2-exp(x)) < tol;
pass(2) = norm( diff(u1)-u1+diff(u2)-1 ) < tol;

f(0,:) = f(0,:);
u = A\f;
u1 = u(:,1); u2 = u(:,2);

err1 = diff(u1)+u1+2*u2-exp(x);
err2 = diff(u1)-u1+diff(u2)-1;
err1.imps = 0*err1.imps;
err2.imps = 0*err2.imps;

pass(3) = norm( err1 ) < tol;
pass(4) = norm( err2 ) < tol;
