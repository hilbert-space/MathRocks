function [x,I] = rescale(x,ends)
% RESCALE Rescale values from [-1,1].
% RESCALE(X,ENDS), where ENDS is a vector with increasing values, 
% rescales X from the interval [ENDS(i) ENDS(i+1)] where it is contained to
% the interval [-1 1]. In case that X is a matrix, each element of X is 
% rescaled using the appropriate interval of ENDS where it is contained.
%
% [Y,I] = RESCALE(X,ENDS) returns the rescaled values Y and the index i
% of the vector ENDS used to rescale X.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

nchebs = length(ends)-1;
I = zeros(size(x));

% Outliers at the left of the domain are computed with the leftmost
% fun.
I((x<ends(1))) = 1;
% Points in the domain are computed with the corresponding fun
for i = 1:nchebs
    a = ends(i); b = ends(i+1);
    I((x>=a)&(x<b)) = i;
end
% Outliers at the right of the domain are computed with the rightmost
% fun.
I((x>=ends(end))) = nchebs;
