function pass = ad_basic2
% This test checks that Automatic Differentiation is working.

% Nick Trefethen, 5 November 2009

tol = 10*chebfunpref('eps');

d = [1 3];
x = chebfun(@(x) x, d);
one = chebfun(1,d);
y = 2*x;
g = y.^2;
h = diff(g);
pass(1) = abs(h(2)-16) < tol;

dgdx = diff(g,x);
dgdx1 = dgdx*one; 
pass(2) = abs(dgdx1(2)-16) < tol;

dhdy = diff(h,y);
q = dhdy*one; 
w = dhdy*x;  
pass(3) = abs(q(2)-4) < tol;
pass(4) = abs(w(2)-16) < tol;