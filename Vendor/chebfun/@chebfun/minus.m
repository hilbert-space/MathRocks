function H = minus(F1,F2)
% -	  Minus.
%
% F-G subtracts chebfun G from F, or a scalar from a chebfun if either
% F or G is a scalar.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

H = F1+(-F2);