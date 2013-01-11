function pass = complexrotation
% This code makes sure a few things are ok if you make them complex,
% e.g. integration, norms, inner products and singular values.
%
% LNT 20 May 2008

f = chebfun(@(x) exp(x));
fi = chebfun(@(x) 1i*exp(x));
g = chebfun('1./(2-x)');
gi = chebfun('1i./(2-x)');
A = [f g];

pass(1) = (sum(fi)==1i*sum(f));
pass(2) = norm(fi)==norm(f);
pass(3) = abs((f'*g)-((1i*f)'*(1i*g))) < 1e-15;
pass(4) = (norm(gi,inf)-norm(g,inf)) < 1e-15;
pass(5) = (norm(fi,1)-norm(f,1)) < 1e-15;
pass(6) = norm(svd(A) - svd(1i*A)) < 1e-15;

