function S = sum(f,dim)
%SUM  Definite Integration of a chebfun2.
%
% G = sum(F,DIM) where DIM is 1 or 2 integrates only over Y or X
% respectively, and returns as its output a chebfun in the remaining
% variable.
%
% G = sum(F) is the same as sum(F,1)
%
% See also SUM2. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if (nargin == 1) % default to integrating in the y direction.
    dim = 1;
end 

if ( dim > 2 )
    error('CHEBFUN2:SUM:dim','Can only integrate over x or y.');
end

S = sum(f.fun2,dim);
if ( ~isempty(S) )
    S = simplify(S);
end

if dim == 1   % transpose the result because the chebfun is in the x-variable.
   S = S.'; 
end

end