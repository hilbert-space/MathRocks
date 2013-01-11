function A = diag(f,d)
% DIAG   Pointwise multiplication operator.
% 
% A = DIAG(F) produces a chebop that stands for pointwise multiplication by
% the chebfun F. The result of A*G is identical to F.*G.
%
% A = DIAG(F,D) is similar, but restricts the domain of F to D.
%
% See also domain/diag, chebop, linop/mtimes.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% if f.funreturn && length(f) == 1 && f(1).nfuns == 1, 
%     A = f(1).funs(1).vals(1); 
%     return
% end

% if nargin < 2, d = domain(f); end

if nargin < 2, 
    d = domain(f);
% elseif f.ends(1) <= d(1) && f.ends(end) >= d(end)
%     f = restrict(f,d);  % This is now dealt with in domain/diag
end

A = diag(d,f); % Call domain/diag