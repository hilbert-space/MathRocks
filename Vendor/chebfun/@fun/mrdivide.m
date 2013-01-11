function F = mrdivide(f,g)
% /	Right scalar divide
% F/C divides the fun F by a scalar C.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

F = f;
if (isa(g,'double'))
    F.vals = f.vals/g;
    F.coeffs = f.coeffs/g;
    F.scl.v = f.scl.v/abs(g);
else
    error('FUN:mrdivide:funfun','Use ./ to divide a fun into a fun.');
end