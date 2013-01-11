function pass = chebop_cumsum
% Check if the indefinite integral chebop works.

d = [4,5.6];
Q = chebop(@(u) cumsum(u),d);
f = chebfun(@(x) exp(sin(x).^2+2),d);
pass = norm(Q*f - cumsum(f)) < chebfunpref('eps');
