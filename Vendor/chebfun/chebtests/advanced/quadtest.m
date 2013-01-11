function pass = quadtest

% Tests sum and quad over bounded domains.
% Pedro Gonnet, June 2011

% (A Level 1 chebtest)

tol = chebfunpref('eps');
f = chebfun( @cos , [0,10] );

pass(1) = abs( sum( f ) - sin(10) ) < tol*10;
pass(2) = abs( quad( f , 0 , 10 ) - sin(10) ) < tol*10;

pass(3) = abs( sum( f , [ 0 , 2 ] ) - sin(2) ) < tol*10;
pass(4) = abs( quad( f , 0 , 2 ) - sin(2) ) < tol*10;
