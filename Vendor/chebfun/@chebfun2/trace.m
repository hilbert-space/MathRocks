function t = trace(f)
% TRACE integral of a chebfun2 along its diagonal 
%
% TRACE(f) is the integral of function f(x,x).
% 
% See also DIAG. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

t = sum(diag(f)); 

end