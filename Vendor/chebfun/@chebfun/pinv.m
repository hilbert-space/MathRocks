function X = pinv(A,tol)
% PINV   Pseudoinverse of a column quasimatrix.
%
% X = PINV(A) produces a row quasimatrix X so that A*X*A = A and
% X*A*X = X.
%
% X = PINV(A,TOL) uses the tolerance TOL.  The computation uses SVD(A) and
% any singular value less than the tolerance TOL is treated as zero.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

if A(1).trans
   error('CHEBFUN:pinv:row','PINV only defined for column quasimatrices.')
end

[U,S,V] = svd(A,0);
s = diag(S);
n = min(size(A));
if nargin==1
   m = 0;
   for i = 1:n
      m = max(m,length(A(:,i)));
   end
   tol = m*eps(max(s)); 
end

r = sum(s>tol);
if r==0
   X = 0*A';
else
   X = V(:,1:r)*diag(ones(r,1)./s(1:r))*U(1:r)';
end
