function N = nargin(L)
% Number of input arguments to a linop.
%  N = nargin(L) returns the number of input arguments of L, i.e., L.blocksize(2);   

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

N = L.blocksize(2);