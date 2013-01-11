function n = nargin(N)
%NARGIN   Number of input arguments to a chebop.
%   n = nargin(N) returns the number of input arguments of the differential
%   operator of N.
%
%   EXAMPLE:
%      >> N = chebop(@(x,u,v) [diff(u),diff(v)]);
%      >> nargin(N)
%      ans = 3

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

n = N.numvar;