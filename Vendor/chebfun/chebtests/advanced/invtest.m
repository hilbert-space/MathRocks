function pass = invtest
% This test constructs two chebfuns and uses inv to invert them.  It checks
% that the inverse calculated is accurate.

% Nick Hale  07/06/2009
tol = chebfunpref('eps');

x = chebfun('x');
f = sin(x);
g = chebfun(@(x) asin(x), [sin(-1),sin(1)]);
finv = inv(f);
pass(1) = norm(g - finv,inf) < 100*tol;

% %  commented for speed
pass(2) = true;
% pass(2) = norm(f - inv(finv),inf) < 100*tol;

% %  commented for speed
pass(3) = true;
% x = chebfun('x',[0,1]);
% f = sqrt(x);
% g = x.^2;
% finv = inv(f,'splitting',true);
% pass(3) = norm(g - finv,inf) < 100*tol;

x = chebfun('x');
f = chebfun(@(x) sausagemap(x));
finv = inv(f);
pass(4) = norm(f(finv)-x,inf) + norm(finv(f)-x,inf) < 200*tol;

function [g,gprime] = sausagemap(s,d)
if nargin<2, d = 9; end % this can be adjusted
c = zeros(1,d+1);
c(d:-2:1) = [1 cumprod(1:2:d-2)./cumprod(2:2:d-1)]./(1:2:d);
c = c/sum(c); g = polyval(c,s);
cp = c(1:d).*(d:-1:1); gprime = polyval(cp,s);


