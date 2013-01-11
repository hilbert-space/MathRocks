function d = minus(d,a)
% -      Translate a domain to the left.
% D-A for domain D and scalar A subtracts A from all of the domain D's
% endpoints and breakpoints.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

d = plus(d,-a);

end