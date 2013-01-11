function C = plus(A,B)
% +  Sum of varmats, with scalar expansion.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

C = op_scalar_expand(@plus,A,B);
end