function pass = maxdegree
% Tests if the maxdegree is working in resampling on and off modes.

pref = chebfunpref; %pref.resmapling = true; 
pref.maxdegree = 100;
warnstate = warning('off','CHEBFUN:auto');

f = chebfun(@(x) sin(200*x),pref);
pass(1) = length(f) == 101;

pref.resampling = false;
f = chebfun(@(x) sin(200*x),pref);
pass(2) = length(f) == 101;

warning(warnstate)



