function pass = linop_bcchange
% Check if changing the boundary conditions of a chebop that has already
% been evaluated works.

tol = chebfunpref('eps');

d = domain(-3,4);
D = diff(d);  I = eye(d);
A = D*D + 4*D + I;
A.lbc = -1;
A.rbc = 'neumann';
f = chebfun( 'exp(sin(x))',d );
u = A\f;

pass(1) = ( abs(u(d(1))+1)<1e-12*(tol/eps));
pass(2) = ( abs(feval(diff(u),d(2)))<2e-11*(tol/eps) );

A.lbc(1) = {eye(d),2};
A.lbc(2) = {D,0};
A.rbc = [];
u = A\f;

pass(3) = ( abs(feval(diff(u),d(1)))<1e-7*(tol/eps) );
pass(4) = ( abs(feval(u,d(1))-2)<1e-7*(tol/eps) );






