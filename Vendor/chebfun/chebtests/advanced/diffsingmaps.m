function pass = diffsingmaps
% Tests the computation of derivatives using DIFF when the 
% chebfuns have singmaps and exponents.
%
% Nick Hale & Rodrigo Platte, Dec 2009

tol = max(4e-8,100*chebfunpref('eps'));

% left
d = [-1,2];
F = @(x) sqrt(1+x)+sin(x);
f = chebfun(@(x) F(x),d,'singmap',[.5 1]);
g = diff(f);
h = diff(g);
d2 = [-.9 2];
f2 = chebfun(F,d2);
g2 = diff(f2);
h2 = diff(g2);

pass(1) = norm(g2-restrict(g,d2));
pass(2) = norm(h2-restrict(h,d2));

% right
d = [-2,1];
F = @(x) sqrt(1-x)+sin(x);
f = chebfun(@(x) F(x),d,'singmap',[1 .5]);
g = diff(f);
h = diff(g);
d2 = [-2 .9];
f2 = chebfun(F,d2);
g2 = diff(f2);
h2 = diff(g2);
pass(3) = norm(g2-restrict(g,d2));
pass(4) = norm(h2-restrict(h,d2));

% both
d = [-2,2];
F = @(x) sqrt(4-x.^2)+sin(x+1);
f = chebfun(@(x) F(x),d,'singmap',[.5 .5]);
g = diff(f);
h = diff(g);
d2 = [-1.9 1.9];
f2 = chebfun(F,d2);
g2 = diff(f2);
h2 = diff(g2);
pass(5) = norm(g2-restrict(g,d2));
pass(6) = norm(h2-restrict(h,d2));

pass = pass < tol;
