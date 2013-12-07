function rect = getdomain(f)
% returns the domain of a fun2. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

u=[-1 1]; rect = f.map.for(u,u); 
end 