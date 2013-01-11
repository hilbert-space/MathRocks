function pass = chebop_systemeig
% Eigenvalue test, inspired by Maxwell's equation.
% The eigenvalues are computed first on a global
% domain, then on a piecewise domain.
% (A level 3 Chebtest)

%% Smooth domain
d = [0 pi];
A = chebop(@(x,u,v) [-u + diff(v), diff(u)], d);
A.lbc = @(u,v) u;
A.rbc = @(u,v) u;

[V D] = eigs(A,5);
lam = diag(D);

lamcorrect = [
 -0.000000000000000                                       
 -0.499999999999999+ 0.866025403784436i
 -0.499999999999999- 0.866025403784436i
 -0.500000000000001+ 1.936491673103704i
 -0.500000000000001- 1.936491673103704i
 ];

pass(1) = norm( lam-lamcorrect, inf ) < 1e-12;

%% Piecewise domain
A.domain = domain(0,pi/2,pi);
[V D] = eigs(A,5);
lam_pw = diag(D);
pass(2) = norm( lam_pw-lamcorrect, inf ) < 1e-12;
