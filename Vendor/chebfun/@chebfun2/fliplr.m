function f = fliplr(f)
%FLIPLR  Flip/reverse a chebfun2 in the x-direction.
%
% G = FLIPLR(F) returns a chebfun2 G with the same domain as F but
% reversed; that is, G(x,y)=F(a+b-x,y), where the domain is [a,b,c,d].
%
% See also FLIPUD.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isempty(f.fun2) ) % check for empty chebfun2.
    return;
end

f.fun2.R = fliplr(f.fun2.R);  % Flip the row slices.