function e = isempty(A)
% ISEMPTY   True for empty oparray.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

e = isempty(A.op) || isempty(A.op{1});

end