function f=mtimes(f,g)
%* MTIMES fun2 multiplication. 
%
% H = MTIMES(F,G) where F or G is a scalar multiplies the fun2 by a scalar.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if( isa(f,'double') )
    g.U = f*g.U;
    g.scl = abs(f)*g.scl;
    f=g;
elseif( isa(g,'double') )
    f.U = g*f.U; 
    f.scl = abs(g)*f.scl;
else
   error('FUN2:mtimes:BothFun2s','mtimes does not support Fun2 * Fun2. Did you mean f.*g?'); 
end
end