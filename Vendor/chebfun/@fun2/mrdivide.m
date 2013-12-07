function F = mrdivide(f,g)
%/ Right scalar divide for fun2. 
% 
% F/G divides the fun2 F by the scalar G.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

F = f;
if ( isa(g,'double') )
    F.U = (F.U).*g;  
    F.scl = F.scl/g;
else
    error('FUN2:mrdivide:fun2fun2','Use ./ to divide a fun2 by a fun2.');
end