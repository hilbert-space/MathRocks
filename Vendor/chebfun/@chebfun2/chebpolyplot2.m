function varargout = chebpolyplot2(f)
%CHEBPOLYPLOT2 Display bivariate Chebyshev coefficients graphically.
% 
% CHEBPOLYPLOT2(F) plots the bivariate Chebyshev coefficients in a stem3
% plot with a semilogy scale. 
%
% H = CHEBPOLYPLOT2(F) returns a handle H to the figure.
%
% See also CHEBPOLYPLOT, CHEBPOLY2.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

tol = chebfun2pref('eps');

%% 
% Compute the bivariate coefficients, truncate them when then fall below
% tolerance for better visual, use stem3.

X = chebpoly2(f); X = abs(X);   % absolute value of coefficients. 
X = rot90(X,2);                 % Rotate (MATLAB's convention)
yl = find(max(X)>tol, 1, 'last'); 
xl = find(max(X,[],2)>tol, 1, 'last');
zl = find(diag(X)>tol, 1, 'last');

% If the diagonal contains only zeros, then zl is empty. Make it zero if zl
% is empty. 
if ( isempty(zl) )
   zl = 0;  
end

xl = max(xl, zl); yl = max(yl, zl); 
X = X(1:xl, 1:yl);            % Truncate off small coeffs for better visual
[yl, xl]=size(X); 

%% 
% Use a stem3 plot changing the axis to log scale. 

[xx, yy] = meshgrid(1:xl, 1:yl);
h = stem3(xx, yy, X, 'fill', 'markerfacecolor',...
                                        'k','markeredgecolor', 'k');
xlabel('j'), ylabel('k')
set(gca,'ZScale', 'log', 'view', [40 20])
set(gca, 'ZLim', [min(X(:))/10,max(10*max(X(:)))])
set(gca, 'XLim', [0 xl]); set(gca, 'YLim', [0 yl])

box off

% output handle
if ( nargout ~=0 )
    varargout = {h};
end

end