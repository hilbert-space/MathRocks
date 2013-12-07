function varargout = size(F,dim) 
%SIZE size of a chebfun2v object
%
% D = SIZE(F) returns a three-element vector D=[K,M,N]. If F is a column
% chebfun2v object then K is the number of components in F, N and M are
% INF. If F is a row vector then K and M are INF and N is the number of 
% components of F. 
%
% [K,M,N] = SIZE(F) returns the dimensions of F as separate output
% variables.
%
% D = SIZE(F,DIM) returns the dimensions specified by the dimension DIM. 
%
% See also CHEBFUN2/SIZE. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

if ( ~F.isTransposed ) 
    if isempty(F.zcheb)
        K = 2; 
    else
        K = 3; 
    end
    M = inf; N = inf; 
else
    if isempty(F.zcheb)
        N = 2; 
    else
        N = 3; 
    end
    K = inf; M = inf; 
end

if nargin == 1
    dim = 0; 
end

if dim == 1 
    varargout = {K};
elseif dim == 2
    varargout = {M}; 
elseif dim == 3
    varargout = {N}; 
elseif dim == 0 && nargin == 1
    if nargout <= 1 
        varargout = {[K, M, N]};
    else
        varargout = {K, M, N}; 
    end
else
    error('CHEBFUN2V:SIZE:DIM','Unrecognised dimension.');
end


end



    