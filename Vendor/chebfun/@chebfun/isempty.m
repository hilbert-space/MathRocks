function isemp = isempty(F)
% ISEMPTY  Test for empty chebfun.
%
% ISEMPTY(F) returns logical true if F is an empty chebfun and false 
% otherwise.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

isemp = true;

for k = 1:numel(F)
    if ~isempty(F(k).ends)
        isemp = false;       
        return
    end
end