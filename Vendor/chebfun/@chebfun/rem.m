function h = rem(x,y)
% REM   Remainder after division of two chebfuns.
%
% REM(X,Y) returns X - n.*Y, where n = fix(X./Y).
%
% See also REM.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

n = fix(x./y);
h = x-n.*y;
