function a = all(f,varargin)
% ALL    True if all elements of a chebfun are a nonzero number
%
% ALL(X,DIM), where X is a quasimatrix, works down the dimension DIM.
% If DIM is the chebfun (continuous) dimension, then ALL returns a
% logical column vector (or row) in which the Jth element is TRUE if 
% all elements of the Jth column (or row) are nonzero. Otherwise, ALL
% returns a chebfun which takes the value 1 where all of the columns
% (or rows) of X are nonzero, and zero everywhere else.
%
% See also CHEBFUN/ANY.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

a = ~any(~f,varargin{:});