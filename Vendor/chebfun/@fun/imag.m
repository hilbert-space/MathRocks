function g = imag(g)
% IMAG	Complex imaginary part
% IMAG(F) is the imaginary part of F.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

gvals = imag(g.vals);
if any(gvals)
    g.vals = gvals;
    g.coeffs = imag(g.coeffs);
    g = simplify(g);
else
    g.vals = 0; g.n = 1; g.scl.v = 0; g.coeffs = 0; g.exps = [0 0];
end