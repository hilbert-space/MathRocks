function R = realsqrt(X)
% REALSQRT Real square root of a chebfun.
%
% REALSQRT(X) is the square root of the chebfun of X.  An error is produced 
% if X is negative or complex.
%
% See also CHEBFUB/SQRT, CHEBFUN/REALLOG.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Check for complex chebfuns
if ~isreal(X)
    error('CHEBFUN:realsqrt:complex','Realsqrt produced complex result.');
end

% Check for negative chebfuns (with a little tolerance)
tol = chebfunpref('eps');
for k = 1:numel(X)
    if any(get(X(k),'vals') < -tol*get(X(k),'scl'))
        error('CHEBFUN:realsqrt:negative','Realsqrt produced complex result.');
    end
end

% X is real positive, so call SQRT.
R = sqrt(X);
        
if ~isreal(R)
    error('CHEBFUN:realsqrt:complexR','Realsqrt produced complex result.');
end

