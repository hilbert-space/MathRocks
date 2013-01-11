function pass = chebop_bc
% Solve two simple linear BVPs, check the solution vs. the exact
% solution and the precision of the boundary conditions.


tol = chebfunpref('eps');
deltol = cheboppref('deltol');
restol = cheboppref('restol');

d = [-3 4];
A = chebop(@(u) diff(u,2) + 4*diff(u) + u, d);

A.lbc = -1;
A.rbc = 'neumann';
f = chebfun( 'exp(sin(x))', d );
u = A\f;

pass(1) = norm( diff(u,2) + 4*diff(u) + u - f ) < deltol*u.scl*(tol/eps);
pass(2) = abs(u(d(1))+1) < restol*u.scl*(tol/eps);
pass(3) = abs(feval(diff(u),d(2))) < restol*u.scl*(tol/eps);

d = [-1 0];
A = chebop(@(u) diff(u,2) + 4*diff(u) + 200*u, d);
A.lbc = @(u) [diff(u)+2*u-1];
A.rbc = @(u) diff(u);
f = chebfun( 'x.*sin(3*x).^2',d );
u = A\f;
du = diff(u);

pass(4) = norm( diff(u,2) + 4*diff(u) + 200*u - f ) < deltol*u.scl*(tol/eps);
pass(5) = abs(du(d(1))+2*u(d(1))-1) < restol*u.scl*(tol/eps);
pass(6) = abs(feval(diff(u),d(2))) < restol*u.scl*(tol/eps);



