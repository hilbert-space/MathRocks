function varargout=cdr(f)
%CDR decomposition of a chebfun2.
% [C,D,R]=CDR(F) produces a diagonal matrix D of size length(F) by
% length(F) and quasimatrices C and R of size inf by length(F) and
% length(F) by inf, respectively such that f(x,y) = C(:,y) * D * R(x,:).
%
% D = CDR(F) returns a vector containing the pivot values used in the
% construction of F. 
%
% See also PIVOTS, SVD. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

mode = chebfun2pref('mode'); % are we in continuous mode?
rect = f.corners;            % get domain of f. 

%%
% Get pivots, column and row slices
d = pivots(f); Cols = f.fun2.C; Rows = f.fun2.R; 

%%
% Output the CDR decomposition
if ( nargout < 1 )
    varargout = {d};
else
    if ( ~mode )
        % need to make everything continuous
        Cols = chebfun(Cols, rect(3:4));
        D = diag(1./d);
        Rows = chebfun(Rows.', rect(1:2)).';
    else
        % everything is already continuous
        D = diag(1./d);
    end
    varargout = {Cols, D, Rows};  % CDR decomposition
end
end