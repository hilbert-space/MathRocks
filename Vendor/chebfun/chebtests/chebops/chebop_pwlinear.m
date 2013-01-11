function pass = chebop_pwlinear
% This test constructs a piecewise-linear chebop and checks 
% the accuracy of the solution for the ODEs:
% u'' + |x+.5|*u = |x| + |x-.5| + 2*sgn(x),
% u(-1) = 3, u(1) = 0.

% NH 08/2010

tol = 1e-9;

d = [-1 1];
x = chebfun(@(x) x, d);
A = chebop(@(x,u) diff(u,2) + abs(x+.5).*u);
A.lbc = @(u) u-3;
A.rbc = @(u) u;
f = abs(x) + abs(x-.5) + 2*sign(x);
u = A\f;

err = A*u-f;
err = set(err,'imps',0*err.imps(1,:));
pass = norm(err,inf) < tol;