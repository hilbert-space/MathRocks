function C = uminus(A)
% -  Negate a linop.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

C = copy(A);
C.varmat = -C.varmat;
C.oparray = -C.oparray;

end