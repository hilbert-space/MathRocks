function f = uminus(f)
% -	  Unary minus.
% 
% -F negates the chebfun2 F.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

f.fun2 = uminus(f.fun2);

end