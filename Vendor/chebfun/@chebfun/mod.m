function h = mod(x,y)
% MOD   Modulus after division of two chebfuns.
%
% MOD(X,Y) is X - n.*Y where n = floor(X./Y)
%
% See also MOD.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

n = floor(x./y);
h = x-n.*y;
