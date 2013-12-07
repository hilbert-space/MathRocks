function e = isempty(d)
% ISEMPTY Tests for empty interval.
% ISEMPTY(D) returns logical true if the domain D has no specified interval.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

e = isempty(d.ends);

end