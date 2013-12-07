function C = complex(A,varargin)
%COMPLEX Construct complex chebfun2 from real and imaginary parts.
%
% C = COMPLEX(A,B) returns the complex chebfun2 A + Bi, where A and B are
% real valued chebfun2 objects with the same domain.
%
% C = COMPLEX(A) for real chebfun2 A returns the complex result C with real
% part A and all zero imaginary part. isreal(C) returns false.
%
% See also IMAG, CONJ, ABS, REAL.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( nargin == 2 )
    if ( ~isreal(A) || ~isreal(B) )
        error('CHEBFUN:COMPLEX:notreal','Inputs must be real valued.');
    end
    C = A + 1i*B;
else
    if ( ~isreal(A) )
        error('CHEBFUN:COMPLEX:notreal','Input must be real valued.');
    end
    C = A + 1e-300*1i;
end
end