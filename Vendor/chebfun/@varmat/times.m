function C = times(A,B)
% .*  Elementwise multiplication of varmats, with scalar expansion.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

C = op_scalar_expand(@times,A,B);

end
 