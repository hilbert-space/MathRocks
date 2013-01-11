function A = vander(f,n)
%VANDER Vandermonde chebfun quasimatrix.
%   A = VANDER(f,n) returns the Vandermonde quasimatrix whose n columns are 
%   powers of the chebfun f, that is A(:,j) = f.^(n-j), j=0...n-1.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if f(1).trans || min(size(f))>1
    error('CHEBFUN:vander:row','input must be a column chebfun')
end

A = ones(domain(f),n);
for j = n-1:-1:1
    A(:,j) = f.*A(:,j+1);
end