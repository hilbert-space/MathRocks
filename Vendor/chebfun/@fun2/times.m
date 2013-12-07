function f=times(f,g)
%.* Fun2 multiplication.
%
% F.*G multiplies fun2 objects F and G, or a fun2 with a double if either F
% or G is a scalar. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isa(f,'double') )
    g.U = f*g.U;
    f=g;
elseif ( isa(g,'double') )
    f.U = g*f.U;
else
    % Check g and f have same domain.
    u=[-1,1];
    if ( ~all(f.map.for(u,u) == g.map.for(u,u)) )
        error('Fun2:mtimes:domain','Domains of Fun2s do not match.');
    end
    % We have to resample because the basis is not a vector space. 
    rect = f.map.for(u,u);
    op = @(x,y) f.feval(x,y).*g.feval(x,y);
    f = fun2(op,rect,'scl');
end
end