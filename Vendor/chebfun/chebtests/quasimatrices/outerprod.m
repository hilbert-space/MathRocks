function pass = outerprod
% This test checks that the outer product of a system of chebfuns is
% working correctly.
% Toby Driscoll  

% (Alex Townsend modified this script because the syntax 
% changed from f*g' to kron(f,g','operator'). Now f*g' generates a low 
% rank chebfun2). 


% Linop outer product
tol = chebfunpref('eps');

d = [0,1];
x = chebfun(@(x) x, d); 
f = [ exp(x), tanh(x) ];
g = [ exp(x), x./(1+x.^2) ];
u = x;

A = kron(f,g','op');
Au = (exp(x) + (1-pi/4)*tanh(x));

% operational form
pass(1) = norm( Au - A*u ) < 1e-12*(tol/eps);

% discrete form
xx = (1+sin(pi*(2*(1:200)'-200-1)/(400-2)))/2;
pass(2) = norm( Au(xx) - A(200)*u(xx) ) < 1e-12*(tol/eps);