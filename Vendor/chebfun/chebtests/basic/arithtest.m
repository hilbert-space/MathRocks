function pass = arithtest
% Test some basic arithmetic operators, i.e. plus, minus, times,
% power and exp.

% Pedro Gonnet, January 2011


% start with a function on [0,10]
f = @(x) sin(x) + sin(x.^2);
cf = chebfun( f , [0,10] );

% create random nodes on which to evaluate f
rand('seed',6178);
xi = 10 * rand(100,1);
fxi = f(xi);

% get the required tolerance
tol = 1000 * chebfunpref('eps') * max(abs(fxi));


% addition of a constant (plus)
g = cf + 1;
pass(1) = norm( g(xi) - (fxi + 1) , inf ) < tol;

% addition of two chebfuns
g = cf + chebfun( @(x) x.^2 , [0,10] );
pass(2) = norm( g(xi) - (fxi + xi.^2) , inf ) < tol;


% subtraction of a constant (minus)
g = cf - 1;
pass(3) = norm( g(xi) - (fxi - 1) , inf ) < tol;

% subtraction of two chebfuns
g = cf - chebfun( @(x) x.^2 , [0,10] );
pass(4) = norm( g(xi) - (fxi - xi.^2) , inf ) < tol;


% multiplication of a chebfun with a constant (times)
g = 2 * cf;
pass(5) = norm( g(xi) - 2*fxi , inf ) < tol;

% multiplication of a chebfun with another chebfun
g = cf .* cf;
pass(6) = norm( g(xi) - fxi.^2 , inf ) < tol;


% compute square of a function (power)
g = cf.^2;
pass(7) = norm( g(xi) - fxi.^2 , inf ) < tol;

% compute the power of a function
g = cf.^pi;
pass(8) = norm( g(xi) - fxi.^pi , inf ) < 1e3*tol;

% compute the exponential of a chebfun (exp)
g = exp(cf);
pass(9) = norm( g(xi) - exp(fxi) , inf ) < tol;
