function out = isempty(g)
% ISEMPTY	True for empty fun
% ISEMPTY(G) returns one if F is an empty fun and zero otherwise.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if numel(g) > 1
    out = 0;
else
    out = isempty(g.vals);
end
