function I = eye(d)
% EYE Identity operator.
% EYE(D) returns a chebop representing the identity for functions defined
% on the domain D.
%
% See also chebop, linop.

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(d)
    I = linop;
else
    I = linop( @(n) mat(d,n), @(u) u, d );
    I.isdiag = 1;
end

end

function I = mat(d,n)
[n map breaks numints] = tidyInputs(n,d,mfilename);
I = speye(sum(n));
end
