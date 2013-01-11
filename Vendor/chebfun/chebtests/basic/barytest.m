function pass = barytest
% Test the evaluation of a chebfun using barycentric interpolation.

% Pedro Gonnet, January 2011

% tolerance
tol = 10 * chebfunpref('eps');

% create a chebfun from a polynomial of known degree
f = @(x) (0.3 - x) .* (-0.7 - x) .* (-0.1 - x) .* (0.9 - x);
x = chebpts( 10 );
fx = f(x);
g = chebfun( fx );

% evaluate this at a random set of nodes xi
xi = 1 - 2*rand(1000,1);
fxi = f(xi);

% pass?
pass = norm( g(xi) - fxi , inf ) < tol * max(abs(fxi));
