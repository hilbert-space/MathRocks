function g = real(g)
% REAL	Complex real part
% REAL(G) is the real part of G.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

gvals = real(g.vals);
if any(gvals)
    g.vals = gvals;
    g.coeffs = real(g.coeffs);
    g = simplify(g);
else
    g.vals = 0; g.n = 1; g.scl.v = 0; g.coeffs = 0; g.exps = [0 0];
end