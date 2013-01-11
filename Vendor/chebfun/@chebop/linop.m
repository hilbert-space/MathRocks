function [L f] = linop(N)
%LINOP Converts a chebop to a linop
% L = LINOP(N) converts a chebop N to a linop L if N is a linear operator.
% If N is not linear, then an error message is returned.
%
% [L F] = LINOP(N) returns also the affine part F of the linear chebop N
% such that L*u + F(x) = N.op(x,u).
%
% See also LINOP, CHEBOP/LINEARISE, CHEBOP/ISLINEAR, CHEBOP/DIFF

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% We will throw an error if the chebop is nonlinear
linCheck = 1; 

if nargout == 1
    [L bc isLin] = linearise(N,[],linCheck);
else
    % We must compute the affine part
    [L bc isLin f] = linearise(N,[],linCheck);
end

% We need the entire operator (including BCs) to be linear
isLin = all(isLin);

% Throw an error is the chebop is nonlinear
if ~isLin
    error('CHEBOP:linop:nonlinear',...
        'Chebop does not appear to be a linear operator.')
end

% Set the fields on the linop to be returned
L = L & bc;
L = set(L,'opshow',N.opshow);
L = set(L,'lbcshow',N.lbcshow);
L = set(L,'rbcshow',N.rbcshow);
L = set(L,'bcshow',N.bcshow);

% Maintain anon function from chebop if possible. (Faster than oparrays?) 
op = N.op;
if isa(op,'function_handle') && nargin(op) <= 2
    if nargin(op) == 2
        x = chebfun(@(x) x, L.domain);
        op = @(u) op(x,u);
    end
    L = set(L,'oparray',op);
elseif isa(op,'linop')
    L = set(L,'oparray',get(op,'oparray'));
end
    
