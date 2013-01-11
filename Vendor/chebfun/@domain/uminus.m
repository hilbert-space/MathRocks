function d = uminus(d)
% -     Negate a domain's defining points.
% -D negates the endpoints and breakpoints of D, and reverses their order.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

d.ends = -d.ends(end:-1:1);

end
