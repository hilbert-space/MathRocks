function f = uminus(f)
%UMINUS unary minus for fun2.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Just take the pivots are put a minus on them.
f.U = -f.U; 

end