function Z = null(A)
% NULL   Null space of a column quasimatrix.
%
% NULL(A) returns an orthonormal basis for the null space of the column 
% quasimatrix A.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if A(1).trans
   error('CHEBFUN:null:row','NULL only defined for column quasimatrices')
end

[U,S,V] = svd(A,0);
s = diag(S);
n = min(size(A));
tol = n*eps(max(s));
r = sum(s>tol);
Z = V(:,r+1:n);
