function r = range(g)
% Range of a fun, i.e. max(g) - min(g)

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ~isreal(g)
    r = range(abs(chebfun(g)));
    return
end

r = diff(minandmax(g));
