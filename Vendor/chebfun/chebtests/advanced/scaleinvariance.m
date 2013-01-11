function pass = scaleinvariance

% This code makes sure a few things are scale-invariant.
% (A Level 1 chebtest)
% Nick Trefethen 20 May 2008

d = [1 2];
scale = 2^300;
f = chebfun(@(x) exp(x),d);
maxf = max(f);

f1 = chebfun(@(x) exp(x*scale),d/scale);
pass(1) = (max(f1)==maxf);

f2 = chebfun(@(x) exp(x/scale),d*scale);
pass(2) = (max(f2)==maxf);

f3 = chebfun(@(x) exp(x)*scale,d);
pass(3) = (max(f3)==maxf*scale);

f4 = chebfun(@(x) exp(x)/scale,d);
pass(4) = (max(f4)==maxf/scale);


