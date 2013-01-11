function B = copy(A)
% Copy a linop into another, preserving everything but the ID number.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

B = A;
B.ID = newIDnum();

end
