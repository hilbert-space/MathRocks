function e = eq(a,b)
% ==     Equality of domains
% Domains are considered equal if their endpoints are identical floating
% point numbers. Breakpoints are not considered.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(a) || isempty(b)
  e = [];
else
  e = isequal( a.ends([1 end]), b.ends([1 end]) );
end

end