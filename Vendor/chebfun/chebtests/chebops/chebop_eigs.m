function pass = chebop_eigs
% Test the chebop eigs method.
% Asgeir Birkisson, December 2010

tol = 1e5*chebfunpref('eps');

%% With linops
d = domain(0,pi);
L = diff(d,2) & 'dirichlet';
[V,D] = eigs(L,10);
diag1 = sqrt(-diag(D));
pass(1) = norm(diag1 - (1:10).',inf) < tol;

%% With chebops
d = [0,pi];
N = chebop(d);
N.op = @(u) diff(u,2);
N.bc = 'dirichlet';
[V,D] = eigs(N,10);
diag2 = sqrt(-diag(D));
pass(2) = norm(diag2 - (1:10).',inf) < tol;

%% Should be the same?
pass(3) = norm(diag1-diag2,inf) == 0;

