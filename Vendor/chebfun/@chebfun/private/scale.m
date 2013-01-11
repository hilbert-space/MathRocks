function X = scale(x,a,b)
% SCALE Scale values to the interval [-1 1]
% Y = SCALE(X,A,B) use the map
%
%    Y = (1-X)*A/2 + (X+1)*B/2
% 
% to scale X between the scalars A and B to a value between -1 and 1.
% X can be a scalar or a matrix.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

X = (1-x)*a/2 + (x+1)*b/2;