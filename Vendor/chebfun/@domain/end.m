function e = end(d,k,m)
% END    Right endpoint of a domain.
% D(END) returns the right endpoint of the domain D. 

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(d)
  e = 0;
else
  e = 2;
end
