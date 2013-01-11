function R = reallog(X)
% REALLOG   Real square root of a chebfun.
%
% REALLOG(X) is the logarithm of the chebfun of X.  An error is produced 
% if X is negative or complex.
%
% See also CHEBFUN/LOG, CHEBFUBN/REALSQRT.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Check for complex chebfuns
if ~isreal(X)
    error('CHEBFUN:reallog:complex','Reallog produced complex result.');
end

% Check for negative chebfuns (with a little tolerance)
tol = chebfunpref('eps');
for k = 1:numel(X)
    if any(get(X(k),'vals') < -tol*get(X(k),'scl'))
        error('CHEBFUN:reallog:negative','Reallog produced complex result.');
    end
end

% X is real positive, so call LOG.
R = log(X);
        
if ~isreal(R)
    error('CHEBFUN:reallog:complexR','Realsqrt produced complex result.');
end

