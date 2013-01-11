function g1 = times(g1,g2)
% .*	Fun multiplication
% G1.*G2 multiplies funs G1 and G2 or a fun by a scalar if either G1 or G2 is
% a scalar.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if (isempty(g1) || isempty(g2)), g1=fun; return; end

% Deal with scalars
if (isa(g1,'double') || isa(g2,'double'))
  g1 = mtimes(g1,g2);
  return;
end  

% Deal with scalar funs
if length(g1.vals) == 1 && ~any(g1.exps)
    g1 = mtimes(g1.vals,g2); return, 
end
if length(g2.vals) == 1 && ~any(g2.exps)
    g1 = mtimes(g1,g2.vals); return
end

% Deal with exps 
% NicH removed this 22/04/2010. Not sure it's needed.
% if any(g2.exps<0), g1 = extract_roots(g1); end
% if any(g1.exps<0), g2 = extract_roots(g2); end
exps = sum([g1.exps ; g2.exps]); % (just have to add!)
 
% Deal with maps
% If two maps are different, call constructor.
if ~samemap(g1,g2)
    x1 = g1.map.for(chebpts(g1.n));
    x2 = g2.map.for(chebpts(g2.n));
    g1 = fun(@(x) bary(x,g1.vals,x1).*bary(x,g2.vals,x2),g1.map.par(1:2));
    g1.exps = exps;
    return
end

% The map is the same, so the length of the product is known.
temp = prolong(g1,g1.n+g2.n-1); 
pos = false;
if isequal(g1,g2)
   vals = temp.vals.^2;          
   if all(isreal(g1.vals)), pos = true; end
elseif isequal(conj(g1),g2)
   vals = conj(temp.vals).*temp.vals;
   pos = true;
else
   temp2 = prolong(g2,g1.n+g2.n-1); 
   vals = temp.vals.*temp2.vals;
end

% Deal with scales:
scl.h = max(g1.scl.h,g2.scl.h);
%scl.v = norm([g1.scl.v; g2.scl.v; vals],inf);
scl.v = norm(vals,inf);
g1.scl = scl;

% Simplify:
g1.vals = vals; g1.n = length(vals); g1.exps = exps; g1.coeffs = [];
g1 = simplify(g1); 

% Funs g1 and g2 are such that their product should be positive. Enforce
% this on the values. (Simplify could have ruined this property).
if pos
    g1.vals = abs(g1.vals);
end
