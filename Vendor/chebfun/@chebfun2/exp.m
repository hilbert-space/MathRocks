function f = exp(f) 
% EXP  Exponential of a chebfun2
%
% EXP(F) returns the exponential of a chebfun2. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(f.fun2), return; end % check for empty chebfun2.

op = @(x,y) exp(f.feval(x,y)); % resample.
rect = f.corners;              % Domain. 
f = chebfun2(op,rect);         % Call constructor.

end