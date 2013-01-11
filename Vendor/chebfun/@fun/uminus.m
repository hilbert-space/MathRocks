function gout = uminus(g)
% -	Unary minus
% -G negates the fun G.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

gout = g; gout.vals = -g.vals; gout.coeffs = -g.coeffs;