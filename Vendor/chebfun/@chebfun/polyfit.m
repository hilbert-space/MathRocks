function f = polyfit(y,n)  
% POLYFIT Fit polynomial to a chebfun.
%
% F = POLYFIT(Y,N) returns a chebfun F corresponding to the polynomial 
% of degree N that fits the chebfun Y in the least-squares sense.
%
% F = POLYFIT(X,Y,N,D) returns a chebfun F on the domain D which 
% corresponds to the polynomial of degree N that fits the data (X,Y) 
% in the least-squares sense.
%
% Note CHEBFUN/POLYFIT does not not support more than one output argument
% in the way that MATLAB/POLYFIT does.
%
% See also POLYFIT, DOMAIN/POLYFIT.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Nick Hale & Rodrigo Platte,  21/01/2009

if nargout > 1
    error('CHEBFUN:polyfit:nargout','Chebfun/polyfit only supports one output');
end

for k = 1:numel(y)
    f(k) = columnfit(y(k),n);
end

function f = columnfit(y,n)

if n > length(y) && y.nfuns == 1
    f = y;
else
    [a,b] = domain(y);
    E = legpoly(0:n,[a,b],'norm');  % Legendre-Vandermonde matrix   
    f = E*(E'*y);                   % least squares chebfun
end
