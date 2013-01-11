function pass = diffsingmaps
% Tests the computation of derivatives using DIFF when the 
% chebfuns are defined on finite domains, but have negative,
% and possibly fractional exponents in order to represent 
% endpoint divergences.

tol = 1e4*chebfunpref('eps');

map = {'sausage',9};

% left
d = [-1,2];
F = @(x) 1./sqrt(1+x).*sin(x);
f = chebfun(@(x) F(x),d,'exps',[-.5 0],'map',map);
g = diff(f);
d2 = [-.9 2];
f2 = chebfun(F,d2);
g2 = diff(f2);
pass(1) = norm(g2-restrict(g,d2));

% right
d = [-2,1];
F = @(x) 1./sqrt(1-x).*sin(x);
f = chebfun(@(x) F(x),d,'exps',[0 -.5],'map',map);
g = diff(f);
d2 = [-2 .9];
f2 = chebfun(F,d2);
g2 = diff(f2);
pass(2) = norm(g2-restrict(g,d2));

% both
d = [-2,2];
F = @(x) 1./sqrt(4-x.^2).*sin(x+1);
f = chebfun(@(x) F(x),d,'exps',[-.5 -.5],'map',map);
g = diff(f);
d2 = [-1.9 1.9];
f2 = chebfun(F,d2);
g2 = diff(f2);
pass(3) = norm(g2-restrict(g,d2));

pass = pass < tol;
