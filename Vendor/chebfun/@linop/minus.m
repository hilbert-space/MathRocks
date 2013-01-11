function C = minus(A,B)
% -  Difference of linops.
% If A and B are linops, A-B returns the linop that represents their
% difference. If one is a scalar, it is interpreted as the scalar times the
% identity operator.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

C = plus(A,-B);
end