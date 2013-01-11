function pass = linop_operarith
% This test checks basic arithmetric operations of linops

d = domain(-1,4);
Q = cumsum(d);
D = diff(d);
f = chebfun(@(x) exp(sin(x).^2+2),d);
F = diag(f);
A = -(2*D^2 - F*Q + 3);
Af = A*f;
pass = norm( Af - (f.*cumsum(f)-2*diff(f,2)-3*f) ) < 1e4*eps;

% One would like to be able to write this in
% a different syntax, as below, but so far this is
% not possible.
% d = [-1,4];
% Q = chebop(@(u) cumsum(u),d);
% D = chebop(@(u) diff(u),d);
% f = chebfun(@(x) exp(sin(x).^2+2),d);
% F = chebop(@(u) f.*u,d);
% A = -(2*D^2 - F*Q + 3);
% Af = A*f;

