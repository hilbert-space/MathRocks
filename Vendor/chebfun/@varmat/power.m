function C = power(A,B)
% .^  Elementwise power of varmats, with scalar expansion.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

C = op_scalar_expand(@power,A,B);

end
