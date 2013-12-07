function l = length(f)
%LENGTH rank of a fun2. 
% 
% L = LENGTH(F) is the number of steps used in the iterative GE
% construction process. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

l = f.rank;   % Number of crosses used. 

end