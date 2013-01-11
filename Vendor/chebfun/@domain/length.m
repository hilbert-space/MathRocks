function l = length(d)
% LENGTH  Length of a domain's interval.
% LENGTH(D) returns the difference between endpoints, D(end)-D(1).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

if isempty(d)
  l = 0;
else
  l = d.ends(end)-d.ends(1);
end

end