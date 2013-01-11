function pass = ctortest
% Test the chebfun constructor for vectorized and non-vectorized
% string and anonymous function inputs.

% Pedro Gonnet, January 2011

% our error bound
tol = chebfunpref('eps') * 100;

% the function we want to construct
f = @(x) sin(x) .* sin(x.^2);

% the nodes at which to evaluate the function
rand('seed',6178);
x = 10 * rand(100,1);
fx =  f(x);

% create the function from a vectorized string on [0,10]
g = chebfun( 'sin(x) .* sin(x.^2)' , [0,10] );
pass(1) = norm( g(x) - fx , inf ) < tol;

% create the function from an unvectorized string on [0,10]
g = chebfun( 'sin(x) * sin(x^2)' , [0,10] );
pass(2) = norm( g(x) - fx , inf ) < tol;

% create the function from the vectorized anonymous function on [0,10]
g = chebfun( f , [0,10] );
pass(3) = norm( g(x) - fx , inf ) < tol;

% create the function from an uvectorized anonymous function on [0,10]
g = chebfun( @(x) sin(x) * sin(x^2) , [0,10] );
pass(4) = norm( g(x) - fx , inf ) < tol;

