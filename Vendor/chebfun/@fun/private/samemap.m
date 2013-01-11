function t = samemap(g1,g2)

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

t = strcmp(g1.map.name,g2.map.name) && isequal(g1.map.par,g2.map.par);

