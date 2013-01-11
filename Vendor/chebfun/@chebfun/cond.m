function out = cond(f)
% COND	 Condition number.
% 
% COND(F) is the 2-norm condition number of F.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

s = svd(f,0);
if any(s==0)
  out = inf;
else
  out = s(1)/s(end);
end
