function C = mrdivide(B,A)
% /   Right matrix divide.
%
% B/A in general gives the least squares solution to X*A = B.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isscalar(A)
    C = B*(1/A);
elseif size(A,2)~=size(B,2)
    error('CHEBFUN:mldivide:agree','Matrix dimensions must agree.')
elseif isa(A,'double')
    % C = B*(eye(size(B,2))/A);
    [Q,R] = qr(B,0);
    C = Q*(R/A);
elseif ~A(1).trans
    [Q,R] = qr(A,0);
    C = (B/R)*Q';
else
    [Q,R] = qr(A',0);
    C = (B*Q)/R';
end
