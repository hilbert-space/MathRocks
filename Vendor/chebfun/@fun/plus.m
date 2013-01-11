function g1 = plus(g1,g2)
% +	Plus
% G1 + G2 adds funs G1 and G2 or a scalar to a fun if either G1 or G2 is a
% scalar.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

g1 = minus(g1,uminus(g2));