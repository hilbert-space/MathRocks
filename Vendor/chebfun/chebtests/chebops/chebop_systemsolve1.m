function pass = chebop_systemsolve1
% Test 2x2 system (sin/cos)
% Toby Driscoll
% (A Level 3 Chebtest)

tol = chebfunpref('eps');

d = [-pi pi];
A = chebop(@(x,u,v) [u - diff(v), diff(u) + v],d);
A.lbc = @(u,v) u + 1;
A.rbc = @(u,v) v;
x = chebfun('x',d);
f = [ 0*x 0*x ];
u = A\f;

u1 = u(:,1); u2 = u(:,2);
pass(1) = norm( u1 - cos(x),inf) < 100*tol;
pass(2) = norm( u2 - sin(x),inf) < 100*tol;

f(0,1) = f(0,1);
u = A\f;

u1 = u(:,1); u2 = u(:,2);
pass(3) = norm( u1 - cos(x),inf) < 2000*tol;
pass(4) = norm( u2 - sin(x),inf) < 2000*tol;

