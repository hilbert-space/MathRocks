function pass = rootspol
% Check behavior of roots of a perturbed polynomial
% Rodrigo Platte, July 2008.
% A level 0 Chebtest.

p = chebfun( '(x-.1).*(x+.9).*x.*(x-.9) + 1e-14*x.^5' );
r = roots(p);

pass(1) = length(r)==4 && norm(p(r),inf)<1e-13*chebfunpref('eps')/eps;

f = chebfun(chebpolyval([0 0 0 0 1 0]));

pass(2) = roots(f) == 0;
