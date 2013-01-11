function [isLin L BC] = islinear(N)
%ISLINEAR Checks whether a chebop is linear.
% ISLINEAR(N) returns 1 if N is a linear operator, 0 otherwise.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

linCheck = true;
[L BC isLin] = linearise(N,[],linCheck);
isLin = all(isLin);

if nargout == 2
    L = L & BC;
end
