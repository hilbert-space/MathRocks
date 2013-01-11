%% Time-independent Schrödinger eqn & reflection coefficients
% Sheehan Olver, 27 September 2010

%%
% (Chebfun example ode/ReflectionCoefficient.m)

%%
% The reflection coefficient acts as the "Fourier transform" for nonlinear 
% integrable PDEs, such as KdV and NLS.  For an initial condition q(x),
% if u solves the time independent Schrodinger equation
%
%     d2u/d2x + (w^2 + q) u = 0
% 
% on (-inf, inf) so that 
%
%     u ~ exp(-i w x) 
%
% at -inf, then 
%
%     u ~ a exp(-i w x) + b exp(i w x)
%
% at inf, where a and b are constants.  The reflection coefficient is then
% the ratio b/a.

%%
% Here we we compute u on (-inf,0] by writing
%
%     u = (p + 1) exp(-i w x),
%
% and solving the non-oscillatory ODE for p
%
%     p'' - 2i*w*p' + q p = q.
%
% We likewise find solutions to the time independent Schrodinger equation
% phip and phim on [0,inf) which satisfy
%
%     phip ~ exp(i w x) and phim ~ exp(-i w x)
%
% We then write
%
%     u = a phim + b phip
%
% on [0,inf) by solving 
%
%     u(0) = a phim(0) + b phip(0) and u'(0) = a phim'(0) + b phip'(0)

warnstate = warning;

tic
w = 2.0;
dneg = domain([-inf,0]);

Dneg = diff(dneg);
qneg = chebfun('sech(x).^2',dneg);
Lneg = Dneg^2 - 2i*w*Dneg+diag(qneg);
Lneg.lbc(1) = 0;

p = Lneg\(-qneg);
pD = diff(p);

dpos = domain([0,inf]);

Dpos = diff(dpos);
qpos = chebfun('sech(x).^2',dpos);
Lposp = Dpos^2 + 2i*w*Dpos+diag(qpos);
Lposp.rbc = 0;
Lposm = Dpos^2 - 2i*w*Dpos+diag(qpos);
Lposm.rbc = 0;

phip = Lposp \ (-qpos);
phim = Lposm \ (-qpos);

phipD = diff(phip);
phimD = diff(phim);

ab = [[phim(0)+1, phip(0)+1],
     [phimD(0)-1i.*w.*(phim(0)+1), phipD(0)+1i.*w.*(phip(0)+1)]] \ ...
       [1 + p(0); pD(0) - 1i.*w.*(p(0)+1)];

soln = ab(2)/ab(1)

%%
% The exact reflection coefficient for this initial condition can be 
% found in [Drazin & Johnson 1989]:
%
truesoln = -0.0016078067215641416 + 0.00308747394810661i

%%
% This matches the computed result to 7 digits.

error = abs(soln - truesoln)
toc

warning(warnstate)
