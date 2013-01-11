function pass = chebop_gmrestest
% Test the Chebfun implementation of GMRES for solving Lu = f, 
% where L is an operator, and both f and u are chebfuns

% Sheehan Olver

tol = chebfunpref('eps');

d = [-1 1];
x = chebfun('x',d);
f = exp(x);
w = 100;
L = chebop(@(u) diff(u) + 1i*w*u, d);

[u,flag] = gmres(L,f);
pass(1) = ~flag;
pass(2) = abs(sum(f.*exp(1i.*w.*x))-(u(1).*exp(1i.*w)-u(-1).*exp(-1i.*w))) < 100*tol;

