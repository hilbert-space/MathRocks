function pass = chebop_scalingtest
% This tests solves a nonlinear pendulum BVP with 
% huge amplitude, to make sure scaling is working ok.
% Nick Trefethen, February 2011.   A Level 4 chebtest.

tol = chebfunpref('eps');
d = [0 10];
N = chebop(d);

% Ordinary scaling:    (commented out to save time)
%N.op = @(u) diff(u,2) + sin(u);
%N.bc = 2;
%N.init = chebfun(@(x) 2*cos(2*pi*x/10),d);
%u = N\0;
%exact = -1.715918559382174;
%pass(1) = norm( u(6) - exact ) < 100*tol;

% Huge amplitude:
s = 2^200;
N.op = @(u) diff(u,2) + s*sin(u/s);
N.bc = 2*s;
N.init = chebfun(@(x) 2*s*cos(2*pi*x/10),d);
u = N\0;
exact = -1.715918559382174*s;
pass = norm( u(6) - exact ) < 100*s*tol;
