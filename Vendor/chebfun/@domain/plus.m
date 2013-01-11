function d = plus(d,a)
% +  Translate a domain to the right.
% D+A and A+D for domain D and scalar A adds A to all of the domain D's
% endpoints and breakpoints.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Swap if needed to make D a domain.
if isnumeric(d)
  t=a; a=d; d=t;
end

if ~isnumeric(a) || numel(a)~=1 || ~isreal(a)
  error('DOMAIN:plus:badoperand','Only real scalars can be added to domains.')
end

d.ends = d.ends+a;

end