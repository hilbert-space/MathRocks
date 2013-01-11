function g = conj(g)
% CONJ	Complex conjugate
% CONJ(F) is the complex conjugate of F.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

g.vals = conj(g.vals);
g.coeffs = conj(g.coeffs);