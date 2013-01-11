function e = double(d)
% DOUBLE Convert domain to double.
% DOUBLE(D) returns a vector containing the endpoints and breakpoints (in
% sorted order) of the domain D.
%
% If you want only the endpoints and not any breakpoints, use D(:).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

e = d.ends;

end