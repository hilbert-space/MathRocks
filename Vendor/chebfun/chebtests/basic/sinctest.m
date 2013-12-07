function pass = sinctest
% Test sinc function construction

% Nick Hale, October 2012

tol = 10*chebfunpref('eps');

% Test the sinc method against a sinc construction
x = chebfun('x');
f1 = sinc(x);
f2 = chebfun(@(x) sin(x)./x);
f3 = sin(x)./x;
pass(1) = norm(f1-f2,inf) < tol;
pass(2) = norm(f1-f3,inf) < tol;

% Do the same on a larger interval
d = [-100 100];
x = chebfun('x',d);
f1 = sinc(pi*x);
f2 = chebfun(@(x) sin(pi*x)./(pi*x),d);
f3 = sin(pi*x)./(pi*x);
pass(3) = norm(f1-f2,inf) < diff(d)*tol;
pass(4) = norm(f1-f3,inf) < diff(d)*tol;


