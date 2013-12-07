function bol = isequal(f,g)
%ISEQUAL Equality test for fun2.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Assume they are equal.
bol = 1; 

% Check the easy -> medium in that order.

% 1. Same rank. 
if (~(f.rank == g.rank))
    bol=0; 
    return; 
end

% 2. Scales the same. 
if ( ~(abs(f.scl - g.scl)<1e-14) ) 
    bol=0; 
    return; 
end

% 3. Same domain. 
u = [-1,1]; 
if ( ~all(f.map.for(u,u) == g.map.for(u,u)) )
    bol=0; 
    return; 
end

% 4. Do they evaluate to the same at an arbitrary pt. 
r = 0.485375648722841; s = 0.800280468888800;
pt = f.map.inv(r,s); % Get pt in domain. 
if ( abs(f.feval(pt(1),pt(2)) - g.feval(pt(1),pt(2))) > 1e-14 ) 
    bol=0; 
    return; 
end

% If they pass 1-4 that's good enough for now. 
end