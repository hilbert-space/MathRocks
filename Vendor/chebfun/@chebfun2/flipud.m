function f = flipud(f)
%FLIPUD  Flip/reverse a chebfun2 in the y-direction.
%
% G = FLIPUD(F) returns a chebfun2 G with the same domain as F but
% reversed; that is, G(x,y)=F(x,c+d-y), where the domain is [a,b,c,d].
%
% See also FLIPLR.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isempty(f.fun2) )
    return;
end

f.fun2.C = flipud(f.fun2.C);  % flip the column slices.