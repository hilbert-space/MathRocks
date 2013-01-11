function f = replace_roots(f)

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Get the exponents
exps = get(f,'exps');
if ~any(exps >= 1)
    return % nothing to do
end

% Get the domain
d = f.map.par(1:2);

% Get the map
map = f.map;

f.exps = [0 0];
mask = exps >= 1;
newexps = exps;
newexps(mask) = exps(mask) - floor(exps(mask));
pow = exps - newexps;

infd = isinf(d);
if any(infd)
    d = [-1 1];  f.map = linear(d);
    s = map.par(3);
    if all(infd),  C = (.5./(5*s)).^sum(exps-newexps);
    else           C = (.5./(15*s)).^sum(exps-newexps); end
else
    C = (2/diff(d)).^sum(exps-newexps);
end

if strcmp(map.name,'linear') || strcmp(map.name,'unbounded');
    f = prolong(f,f.n+sum(pow));
    x = get(f,'points');
    mult = (x-d(1)).^pow(1).*(d(2)-x).^pow(2);
    f.vals = mult.*f.vals;
    f.coeffs = []; f.coeffs = chebpoly(f);
    f.scl.v = norm(f.vals,inf);
else
    mult = fun(@(x) (x-d(1)).^pow(1).*(d(2)-x).^pow(2),map);
    f = f.*mult;
end
f = C*f;    
f.exps = newexps;

if any(infd)
    f.map = map;
end