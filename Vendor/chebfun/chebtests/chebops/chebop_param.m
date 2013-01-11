function pass = paramODE
% Test solving a parameter dependent ODE. 
% Nick Hale, August 2011

%% Simple problem

% Natural setup
N = chebop(@(x,u,a) x.*u + .001*diff(u,2) + a);
N.lbc = @(u,a) [u + a + 1, diff(u)];
N.rbc = @(u,a) u - 1;
u = N\0;

% Forced setup using a system
N = chebop(@(x,u,a) [x.*u + .001*diff(u,2) + a, diff(a)]);
N.lbc = @(u,a) [u + a + 1, diff(u)];
N.rbc = @(u,a) u - 1;
v = N\0;

pass(1) = norm(u-v) < 1e-10;

return

%% More complicated (systems + 2 params)

x = chebfun('x');
N = chebop(@(x,u,a,b,v) [x.*v + .001*diff(u,2) + a + 2*b, diff(v)-u],[-1 0 1]);
N.lbc = @(u,a,b,v) [u+a, diff(u)];
N.rbc = @(u,a,b,v) [u, diff(u)-a, v-b];
rhs = [sin(x) 1];
u = N\rhs;

err = N(u)-rhs;
err1 = err(:,1); err1.imps = 0*err1.imps(1,:);
err2 = err(:,2); err2.imps = 0*err2.imps(1,:);
err = norm(err1,inf) + norm(err2,inf);

pass(2) = err < 1e-10;

