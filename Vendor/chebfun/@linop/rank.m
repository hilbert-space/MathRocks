function r = rank(A)
%RANK  The rank of a linear chebop. (Ranks above 20 are considered as inf.)
%
% See also linop/svds.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

r = inf;
n = 21;
% compute first n singular values
S = svds(A,n); 
if length(S) < n,
    r = length(S);
end;

end
