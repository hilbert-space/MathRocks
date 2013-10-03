function pass = chebop_v4tests
% Test a few things concerning the version 4 chebops (i.e.
% with nonlinear as well as linear capabilities.)
%     LNT & TAD 4 Dec. 2009.


tol = 1e4*chebfunpref('eps');

d = [-1 1];
x = chebfun(@(x) x, d);
N = chebop(d);
N.op = @(u)0.01*diff(u,2)+x.*u;
N.lbc = 'dirichlet';
N.rbc = 1;
u = N\0; 
pass(1) = (abs(u(.5)-0.0345) < .1);

N = chebop(@(u) diff(u,2),'neumann');
initial = 1-x.^6;
final = expm(.1*N)*initial;
pass(2) = (abs(sum(initial-final))<2*tol);

e = eigs(N);
pass(3) = (abs(e(3)+9.869604)<.1);

d = [-1 1];
x = chebfun(@(x) x, d);
N = chebop(d,@(u) diff(u,3) + sinh(u),@(u)[u+1,diff(u)],1);
N.guess = x;
u = N\0;

pass(4) = abs(u(.25)+.3709) < 0.01;
