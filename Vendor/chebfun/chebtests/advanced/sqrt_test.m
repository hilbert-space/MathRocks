function pass = sqrt_test
% Tests representations of the square root
% function using singularities declared by 'exps'
% (A Level 1 chebtest)
%
% Nick Hale, December 2009

tol = 1e2*chebfunpref('eps');

x = chebfun('x',[0 1]);
f = sqrt(x);
g = chebfun('sqrt(x)',[0 1],'exps',[.5 0]);
pass(1) = norm(f-g,inf) < tol; 

x = chebfun('x');
f = sqrt(x);
g = chebfun('sqrt(x)',[-1:1],'exps',[0 .5 0]);
pass(2) = norm(f-g,inf) < tol; 
