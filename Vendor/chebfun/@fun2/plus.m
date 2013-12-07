function f = plus(f,g)
%PLUS summation for fun2.
% 
% H = PLUS(F,G) where F is a double or fun2, and G is a double or fun2. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isa(f, 'double') && isa(g, 'fun2') )    % double + fun2
    op = @(x,y) f + g.feval(x,y);
    
    % both have the same domain so take one of them.
    rect = g.map.for([-1,1],[-1,1]);
    
elseif ( isa(g, 'double') && isa(f, 'fun2') )  % fun2 + double 
    op = @(x,y) g + f.feval(x,y);
    
    % take one of them.
    rect = f.map.for([-1,1],[-1,1]);
elseif( isa(f, 'fun2') && isa(g, 'fun2') )    % fun2 + fun2 
    % Check for the domains match
    u = [-1,1]; % unit domain.
    if(~ all(norm((f.map.for(u,u) - (g.map.for(u,u))))< eps))
        error('FUN2:plus:maps','The domains of the two fun2s are inconsistent');
    end
    
    % Have to resample - I'm afraid.
    op = @(x,y) f.feval(x,y) + g.feval(x,y);   
%     % both have the same domain so take one of them.
     rect = f.map.for([-1,1], [-1,1]);
else
    % We have resolved what 
   error('FUN2:plus:wrongtype','Plus adds together two fun2s or one fun2 and a double.');
end
    f = fun2(op, rect,'scl');
end
