function F = ctranspose(F)
% '	  Complex conjugate transpose.
% 
% F' is the complex conjugate transpose of F.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

F = transpose(conj(F));
