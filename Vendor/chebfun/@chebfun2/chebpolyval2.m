function varargout = chebpolyval2(F)
%CHEBPOLYVAL2 values on a tensor Chebyshev grid.
%
% X = CHEBPOLYVAL2(F) returns the matrix of values of F on a tensor Chebyshev
% grid. 
%
% [U D V]=CHEBPOLYVAL2(F) returns the low rank representation of the values
% of F on a tensor Chebyshev grid. 
%
% See also CHEBPOLY2, CHEBPOLYPLOT2. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.


mode = chebfun2pref('mode');

if ( nargout <= 1 )
    X = chebpoly2(F);  % get tensor coefficients.
    X = chebpolyval2(X); % convert them to values.
    varargout = {X};
elseif (nargout > 1) 
    g=F.fun2; CC = g.C; RR = g.R; % get fun2 information. 
    % Return the matrix of values in low rank form.
    if ( mode )
        A = [CC.vals]; % convert columns to coefficients.
        D = diag(1./g.U);
        B = [RR.vals].';% convert rows to coefficients.
    else
        A = CC;
        D = diag(1./g.U);
        B = RR;
    end
    varargout = {A, D, B}; 
end

end