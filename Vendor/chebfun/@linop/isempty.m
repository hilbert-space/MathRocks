function e = isempty(A,str)
% ISEMPTY   True for empty linop.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin == 2 && strcmp(str,'bcs')
    e = isempty(A.lbc) && isempty(A.rbc) && isempty(A.bc);
else
    e = isempty(A.varmat) && isempty(A.oparray);
end

end