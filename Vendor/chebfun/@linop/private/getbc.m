function bc = getbc(A)
% Unites the left bc and right bc into a single structure.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

bc = struct('left',A.lbc,'right',A.rbc,'other',A.bc);

end