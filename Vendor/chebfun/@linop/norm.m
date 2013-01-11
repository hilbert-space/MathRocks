function nrm = norm(A,varargin)
%NORM  The operator L2 norm of a linear chebop.
% If the largest singular value fails to converge, inf is returned.
%
% See also linop/svds.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.


nrm = inf;
% compute first singular value
[U,S,V,flag] = svds(A,1);
if ~flag,
    nrm = S(1,1);
end
if flag && isfinite(S(1,1)) && get(A,'difforder') < 1,
    nrm = S(1,1);
    warning('chebfun:linop:norm','Operator is difficult to resolve, result may be inaccurate.');
end

end
