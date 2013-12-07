function f = diff(f,n,dim)
%DIFF Componentwise derivative of a chebfun2v.
%
% DIFF(F) is the derivative of each component of F along the y direction.
%
% DIFF(F,N) is the Nth derivative of each component of F in the y direction.
%
% DIFF(F,N,DIM) is the Nth derivative of F along the dimension DIM.
%     DIM = 1 (default) is the derivative in the y-direction.
%     DIM = 2 is the derivative in the x-direction.
%
% DIFF(F,[NX NY]) is the partial derivative of NX of F in the first 
% variable, and NY of F in the second derivative. For example, DIFF(F,[1
% 2]) is d^3F/dxd^2y.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isempty(f) ) % check for empty chebfun2.
    return;
end

if ( nargin == 1 ) % defaults.
    n = 1;
    dim = 1;
end
if ( nargin == 2 ) 
    if length(n) == 1 
        dim = 1; % diff in y is default.
    elseif length(n) == 2
        f.xcheb = diff(f.xcheb,n);
        f.ycheb = diff(f.ycheb,n);
        f.zcheb = diff(f.zcheb,n);
        return;
    else
        error('CHEBFUN2V:DIFF:INPUT','Cannot diff in more than two variables.');
    end
end

if ( isempty(n) )  % empty n defaults to y-derivative.
    n = 1;
end

% Just diff each component. 
f.xcheb = diff(f.xcheb,n,dim);
f.ycheb = diff(f.ycheb,n,dim);
f.zcheb = diff(f.zcheb,n,dim);

end