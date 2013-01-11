function pass = fzerotest

% Tests the fzero wrapper.
% Pedro Gonnet, June 2011

% (A Level 1 chebtest)

tol = 100*chebfunpref('eps');
f = chebfun( @cos , [0,10] );

pass(1) = abs( fzero( f , 1.5 ) - pi/2 ) < tol;
pass(2) = abs( fzero( f , [ 1 , 2 ] ) - pi/2 ) < tol;
pass(3) = abs( fzero( f , [ 1 , 10 ] ) - pi/2 ) < tol;
