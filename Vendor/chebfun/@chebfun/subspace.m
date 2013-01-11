function theta = subspace(A,B)
%SUBSPACE Angle between subspaces.
%   SUBSPACE(A,B) finds the angle between two subspaces specified by the
%   chebfun columns of the quasimatrices A and B. 
%
%   If the angle is small, the two spaces are nearly linearly dependent.

%   References:
%   [1] A. Bjorck & G. Golub, Numerical methods for computing
%       angles between linear subspaces, Math. Comp. 27 (1973),
%       pp. 579-594.
%   [2] P.-A. Wedin, On angles between subspaces of a finite
%       dimensional inner product space, in B. Kagstrom & A. Ruhe (Eds.),
%       Matrix Pencils, Lecture Notes in Mathematics 973, Springer, 1983,
%       pp. 263-285.
%   [3] A. V. Knyazev and M. E. Argentati, Principal Angles between Subspaces
%       in an A-Based Scalar Product: Algorithms and Perturbation Estimates. 
%       SIAM Journal on Scientific Computing, 23 (2002), no. 6, 2009-2041.
%       http://epubs.siam.org:80/sam-bin/dbq/article/37733

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ~(isa(A,'chebfun') && isa(B,'chebfun'))
    error('CHEBFUN:subspace:argin', ...
        'Both A and B must be column quasimatrices')
end

A = orth(A);
B = orth(B);

C = A'*B;
S = svd(C);
cos_theta = min(S); % cos of the angle (see [3])

% is the angle large? 
if cos_theta < 0.8 
    theta = acos(min(1,cos_theta));    
else 
% if the angle is small, recompute using sine formulation   
    if size(A,2) < size(B,2) 
        sin_theta = norm(A-B*C');
    else
        sin_theta = norm(B-A*C);
    end
    theta = asin(min(1,sin_theta)); 
end