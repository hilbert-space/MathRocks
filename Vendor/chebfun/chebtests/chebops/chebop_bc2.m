function pass = chebop_bc2
% Test nonseperable boundary conditions and other supplementary conditions 

tol = chebfunpref('eps');
deltol = cheboppref('deltol');

%% Linear
N = chebop(@(x,u) diff(u,2) + u,[-2 1]);
N.bc = @(x,u) [feval(diff(u),0), sum(u)];
x = chebfun(@(x) x, N.domain);
rhs = sin(x);
u = N\rhs;

err1 = norm( N(x,u) - rhs );
pass(1) = err1 < deltol*u.scl*(tol/eps);
err2 = N.bc(x,u);
pass(2) = norm(err2) < deltol*u.scl*(tol/eps);

%% Nonlinear

N = chebop(@(x,u) diff(u,2) + sin(u),[-1 1]);
N.bc = @(x,u) [feval(diff(u),0), sum(u)];
x = chebfun(@(x) x, N.domain);
rhs = sin(x);
u = N\rhs;

err3 = norm( N(x,u) - rhs );
pass(3) = err3 < deltol*u.scl*(tol/eps);
err4 = N.bc(x,u);
pass(4) = norm(err4) < deltol*u.scl*(tol/eps);

return % Skip for speed

%% Nonlinear System
N = chebop(@(x,u,v) [diff(u,2) + sin(v),  diff(v,2) + (u)],[-1 1]);
N.lbc = @(u,v) v;
N.bc = @(x,u,v) [sum(u), u(1)-v(-1), feval(diff(u),1)-feval(diff(v),-1)];
rhs = [1 1];
uv = N\rhs;

x = chebfun(@(x) x, N.domain);
u = uv(:,1); v = uv(:,2);
err5 = norm( N(x,u,v) - rhs );
pass(5) = err5 < deltol*u.scl*(tol/eps);
err6 = N.bc(x,u,v);
pass(6) = norm(err6) < deltol*u.scl*(tol/eps);




