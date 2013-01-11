function C = complex(A,B)
% COMPLEX   Construct complex chebfun from real and imaginary parts.
% 
% C = COMPLEX(A,B) returns the complex result A + Bi, where A and B are
% chebfuns with the same number of columns on the same domain.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ~isreal(A) | ~isreal(B)
  error('CHEBFUN:complex:notreal','Inputs must be real.');
end

C = A + 1i*B;
