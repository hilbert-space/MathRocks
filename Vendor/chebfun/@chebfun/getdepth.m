function d = getdepth(f)
% GETDEPTH Obtain the AD depth of a chebfun.
%
% D = GETDEPTH(F) returns the depth of the anon stored in the chebfun F.
%
% Due to its extensive use, this operation is carried out in this special
% function rather than in @chebfun/get.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.
% d= 1;
d = getdepth(f.jacobian);
end