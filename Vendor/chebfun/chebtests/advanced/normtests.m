function pass = normtests
% This test checks that norm of a chebfun is working correctly 
% on abs related functions.
% Nick Trefethen  22 March 2009

tol = 100*chebfunpref('eps');
x = chebfun('x');
absx = abs(x);
pass(1) = (norm(absx,1)==1);
pass(2) = norm(2^(-500)*x)==2^(-500)*norm(x);
% 
dabsx = diff(abs(x));
pass(3) = (norm(dabsx,1)==2);
pass(4) = (norm(dabsx,inf)==1);
pass(5) = (norm(-dabsx,inf)==1);
% 
ddabsx = diff(diff(absx));
pass(6) = (norm(ddabsx,1)==2);
pass(7) = (norm(-ddabsx,1)==2);
pass(8) = (norm(ddabsx,inf)==inf);
pass(9) = (norm(-ddabsx,inf)==inf);
pass(10) = (abs(norm([1 x])-sqrt(8/3)) < tol);
pass(11) = (abs(norm([1 x],2)-sqrt(2)) < tol);


