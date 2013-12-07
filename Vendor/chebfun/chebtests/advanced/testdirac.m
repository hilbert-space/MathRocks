function pass = testdirac
% Tests the construction and operations on the Dirac-Delta function
% on bounded domains
%
% Mohsin Javed, August 2012
% (A Level 1 Chebtest)

tol = 100*chebfunpref('eps');
x = chebfun('x');

% No impulse, zero chebfun
d = dirac(x-2);              
pass(1) = all(abs(d.imps(2,:)) < 100*tol );

% Impulse of unit magnitude at x=0
d = dirac(x);                
pass(2) = abs(d.imps(2,2)-1) < 100*tol;

% Impulses of magnitued 1/2 at -1 and 1
d = dirac((1-x.^2));         
pass(3) = all( abs(d.imps(2,:) - .5) < 100*tol );

% Impulses of magnitude 1/pi at -1, 0 and 1
d = dirac(sin(pi*x));        
pass(4) = all( abs(d.imps(2,:) - [1/pi 1/pi 1/pi]) < 100*tol );

% Impulses at -1, 0 and 1
d = dirac((x.^3-x).*exp(x)); 
pass(5) = all( abs(d.imps(2,:) - [exp(1)/2 1 1/(2*exp(1))]) < 100*tol);

% sum of delta functions
d = dirac(x)+dirac(x-1)+dirac(x,1);
pass(6) = abs(sum(d)-2) < 100*tol;

% absolute value of delta fnctions
d = abs(-dirac(x-1)+dirac(x+1));
pass(7) = abs(sum(d)-2) < 100*tol;

% 1-norm of delta functions
d = norm(dirac(x-.5)-2*dirac(x)+dirac(x-.5),1);
pass(8) = abs(d-4) < 100*tol;

% 2-norm of a delta function
d = norm(dirac(x),2);
pass(9) = isinf(d);

% inf-norm of a delta function
d = norm(dirac(x),inf);
pass(10) = isinf(d);
    