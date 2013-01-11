function P = pinv(A,varargin)
%PINV  The pseudo-inverse of a finite-rank linear chebop.
% If the 20 smallest singular values fail to converge, an error is
% returned.
%
% See also linop/svds.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

r = inf;
n = 21;
% compute smallest n singular values
[U,S,V,flag] = svds(A,n,0); 
if length(S) < n && ~flag,  % that's fine: finite rank and all svals found
    P = V*inv(S)*U';
    return
end
if length(S) < n && flag,   % finite rank but svals inaccurate
    warning('chebfun:linop:pinv','Operator is difficult to resolve, result may be inaccurate.');
    P = V*inv(S)*U';
    return
end;

if length(S) == n && ~flag, % 20 svals found but there may be more
    warning('chebfun:linop:pinv','Pseudoinverse only approximate, as there are too many singular values close to zero.');
    P = V*inv(S)*U';
    return
end;

error('chebfun:linop:pinv','Pseudoinverse could not be computed as nonzero singular values seem to cluster at zero.');

end
