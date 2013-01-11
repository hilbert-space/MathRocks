function pass = chebop_ellipjode
% Test to check that the chebfun command for
% Jacobi elliptic functions ELLIPJ produces a similar 
% result to the solution of the nonlinear differential 
% equation that generates it.

tol = cheboppref('restol');

% Elliptic parameter
m = .1;
K = ellipke(m);
d = [0,K];
x = chebfun(@(x) x, d);

% jacobi elliptic functions
[sn cn dn] = ellipj(x,m); 

% SN is the solution of an ODE
N = chebop(d);
N.op = @(u) diff(u,2) + (1+m)*u - 2*m*u.^3;
N.lbc = @(u) u;
N.rbc = @(u) u - 1 ;
u = N\0;

pass(1) = norm(u-sn,inf) < tol;

return

% We could also do the other elliptic functions,
% CN & DN, but these are inaccurate and fail...

% CN
f = @(u) diff(u,2) + (1-2*m)*u + 2*m*u.^3;
g.left = @(u) u - 1 ;
g.right = @(u) u ;
u = solvebvp(f,g,d);

pass(2) = norm(u-cn,inf) < tol;

% DN
f = @(u) diff(u,2) - (2-m)*u + 2*u.^3;
g.left = @(u) u - 1 ;
g.right = @(u) u - sqrt(1-m);
u = solvebvp(f,g,d);

pass(3) = norm(u-dn,inf) < tol;


