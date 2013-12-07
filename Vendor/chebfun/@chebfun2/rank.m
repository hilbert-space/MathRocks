function r = rank(F,tol)
% RANK   Rank of a chebfun2.
%
% RANK(F) produces an estimate of the rank of the approximant F. Note that
% RANK(F)<=LENGTH(F) since 
%
% RANK(F,TOL) is the number of singular values of F greater than TOL/N, 
% where N is the first singular value of F.
%
% See also LENGTH.

% Copyright 2013 by The University of Oxford and The Chebfun2 Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun2 information.


% compute singular values. 
s = svd(F); 

if isempty(s) % check for empty function. 
    r = []; 
    return;
end

if max(abs(s))==0  %check for zero function. 
    r = 0; 
    return; 
end

if nargin == 2
    r = find(abs(s)>tol./s(1)); 
else
    r = length(s); 
end

end