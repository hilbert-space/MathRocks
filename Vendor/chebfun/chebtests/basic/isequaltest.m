function pass = isequaltest
% Check if chebfun/isequal works by comparing a chebfun with itself
% and with a chebfun constructed from the same function.

% Pedro Gonnet, January 2011

% a function on which to base our funs
f = @(x) sin(x) .* sin(x.^2);
cf = chebfun( f , [ 0 , 10 ] );

% check if the chebfun is equal to itself
pass(1) = isequal( cf , cf );

% make a chebfun of the exact same fun
g = chebfun( f , [ 0 , 10 ] );
pass(2) = isequal( cf , g );
