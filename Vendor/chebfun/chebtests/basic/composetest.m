function pass = composetest
% Test composition of chebfuns with chebfuns and chebfuns
% with functions.
% Also tests if compositions of quasimatrices work.

% Rodrigo Platte, May 2009

% Set tolerance
tol = chebfunpref('eps')*10;

% Smooth functions
x = chebfun('x');
f = sin(x);
g = chebfun('sin(sin(x))');
pass(1) = norm(f(f) - g) < 10*tol;

% Functions with jumps:
h = chebfun(@(x) sign(x), [-2 0 2], 'splitting',1);
fh = chebfun(@(x) sin(sign(x)), [-2 0 2], 'splitting',1);
pass(2) = norm(f(h) - fh, inf) < tol;

% Function handles;
g = @(x) abs(x);
f = x.^2;
pass(3) = norm(f(g) - f, inf) < tol;

% Quasimatrices:
x = chebfun('x',[0 1]);
f = chebfun(@sin);
X = [1 x x.^2];
pass(4) =  norm(f(X) - sin(X),inf) < tol;

XX = X(X);
XX2 = [1 x x.^4];
pass(5) =  norm(XX - XX2,inf) < tol;



