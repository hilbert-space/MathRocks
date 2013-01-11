function pass = exact_endpoints
% Test whether endpoints are interpolated (exactly):
% Rodrigo Platte, May 2009

s = chebfunpref('splitting');
splitting on

f = chebfun(@(x) sin(500*x));
ends = f.ends;
pass = all(f(ends) == sin(500*ends));

chebfunpref('splitting',s);
