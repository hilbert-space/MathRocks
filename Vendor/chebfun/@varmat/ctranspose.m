function C = ctranspose(A)
% CTRANSPOSE  Conjugate transpose of a varmat.
  
% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

C = varmat( @(n) feval(A,n)' );

end