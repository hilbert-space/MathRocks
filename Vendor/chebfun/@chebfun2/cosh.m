function f = cosh(f)
%COSH Hyperbolic cosine of a chebfun2.
%
%  COSH(F) returns the hyperbolic cosine of F. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(f) % check for empty chebfun2.
    return; 
end 

op = @(x,y) cosh(f.feval(x,y));  % Resample. 
rect = f.corners;               % Domain.
f = chebfun2(op,rect);          % Call constructor. 

end