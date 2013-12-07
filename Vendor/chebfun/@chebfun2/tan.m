function f = tan(f)
% TAN   Tangent of a chebfun2.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(f)  % check for empty chebfun2.
    return;
end

op = @(x,y) tan(f.feval(x,y)); % resample
rect = f.corners;              % Domain.
f = chebfun2(op,rect);         % Call constructor.

end