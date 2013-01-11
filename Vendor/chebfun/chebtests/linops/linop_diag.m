function pass = linop_diag
% Check if multiplication with a pointwise multiplication operator
% is identical to a pointwise multiplication of two chebfuns.

tol = chebfunpref('eps');

d = [0,2];
x = chebfun('x',d);
f = sin(exp(2*x));
g = x.^3-cos(x);

% Operator mode
F = diag(f);
pass(1) = norm( F*g - f.*g ) < tol;

% Apply mode
F = linop( @(n) diag( f(1-cos(pi*(0:n-1)/(n-1)))), [], d, 0);
pass(2) = norm( F*g - f.*g ) < 500*chebfunpref('eps');
