function varargout = size(F,dim)
% SIZE   Size of a chebfun2
%
% D = SIZE(F) returns the two-element row vector D = [inf,inf]. 
%
% [M,N] = SIZE(F)  returns M = inf and N = inf.
%
% M = SIZE(F,DIM) returns the dimension specified by the scalar DIM, which
% is always inf.

% Copyright 2013 by The University of Oxford and The Chebfun2 Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun2 information. 

% always return inf, but check the output size.
m = inf; n = inf; 

if nargin == 1 
    if nargout == 2
        varargout = {m ,n};
    else
        varargout = {[m ,n]};
    end
elseif dim==1
    varargout = {m};
else
    varargout = {n};
end

end