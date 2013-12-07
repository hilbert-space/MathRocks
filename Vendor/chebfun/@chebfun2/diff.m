function f = diff(f,order,dim)
%DIFF Derivative of a chebfun2.
%
% DIFF(F) is the derivative of F along the y direction.
%
% DIFF(F,N) is the Nth derivative of F in the y direction.
%
% DIFF(F,N,DIM) is the Nth derivative of F along the dimension DIM.
%     DIM = 1 (default) is the derivative in the y-direction.
%     DIM = 2 is the derivative in the x-direction.
%
% DIFF(F,[NX NY]) is the partial derivative of NX of F in the first 
% variable, and NY of F in the second derivative. For example, DIFF(F,[1
% 2]) is d^3F/dxd^2y.
%
% See also GRADIENT, SUM, PROD.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isempty(f) ) % check for empty chebfun2.
    return;
end

if ( nargin == 1 ) % defaults.
    order = 1;
    dim = 1;
end
if ( nargin == 2 ) 
    if length(order) == 1 % diff in y is default.
        dim = 1;
    elseif length(order) == 2
            rect = f.corners;
            f = diff(chebfun2(diff(f.fun2,order(1),2),rect),order(2),1);
            return;
    else
       error('CHEBFUN2:DIFF','Undetermined direction of differentiation.'); 
    end
end
if ( isempty(order) )  % empty n defaults to y-derivative.
    order = 1;
end

rect = f.corners;
if ( ~( dim == 1 ) && ~( dim == 2) )
    error('CHEBFUN2:DIFF:dim','Can compute derivative in x or y only.');
end

% Differentiate the fun2
f = chebfun2(diff(f.fun2,order,dim),rect);

end