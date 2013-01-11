function pass = inverseq
% This test checks roots and the vectorise preference

tol = 100*chebfunpref('eps');

f = chebfun('(x.^2+4*x-1)/4');
g = chebfun(@(x) roots(x-f),'vectorise','resampling','off','blowup','off');
h = chebfun(@(x) roots(x-g),'vectorise','resampling','off','blowup','off');

h = simplify(h,tol);

pass(1) = (norm(f-h,inf) < tol);
pass(2) = (length(f) == length(h));
