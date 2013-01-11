% Tests the Chebfun residue command.
% Joris Van Deun, 7 December 2009
function pass = residuetest

tol = max(1e-13, chebfunpref('eps')*1e2);

f = chebfun('(x-1.1).*(x.^2+1).*(x-10i)');
g = chebfun('x.^5');

[r,p,k] = residue(g,f);
[G,F] = residue(r,p,k);

pexact = [10i;1.1;-1i;1i];
pass(1) = (norm(sort(real(p))-sort(real(pexact)))  ...
       + norm(sort(imag(p))-sort(imag(pexact)))< tol);
pass(2) = (norm(g./f-G./F) < tol);
pass(3) = (norm(k-chebfun('x+10i+1.1')) < tol);
