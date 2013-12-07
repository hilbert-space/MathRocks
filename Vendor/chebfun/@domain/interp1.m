function p = interp1(xk,yk,d,method)
% INTERP1   Chebfun polynomial interpolant at any distribution of points.
% P = INTERP1(X,F), where X is a vector and F is a chebfun, returns the
% chebfun P defined on domain(F) corresponding to the polynomial
% interpolant of degree N+1 through F(X(j)) at points X(j), j = 1,...,N.
%
% P = INTERP1(X,Y,D), where X and Y are vectors and D is a domain, returns
% the chebfun P defined on D corresponding to the polynomial interpolant
% through data Y(j) at points X(j).
%
% If Y is a matrix with more than one column or F is a chebfun quasimatrix
% with more than one column, then P is a quasimatrix with each column
% corresponding to the appropriate interpolant.
%
% For example, these commands plot the interpolant in 11 equispaced points
% on [-1,1] through the famous Runge function:
%
%  EXAMPLE:
%    d = [-1 1];
%    ff = @(x) 1./(1+25*x.^2);
%    x = linspace(d(1),d(2),11);
%    p = interp1(x,ff(x),domain(d))
%    plot(chebfun(ff,d),'k',p,'r',x,ff(x),'.r'), grid on
%
% P = interp1(X,F,METHOD) or P = interp1(X,Y,D,METHOD) specifies alternate
% methods. The default is as described above. (Use an empty matrix [] to
% specify the default.) Available methods are:
%   'linear'   - linear interpolation
%   'spline'   - piecewise cubic spline interpolation (SPLINE)
%   'pchip'    - shape-preserving piecewise cubic interpolation
%   'cubic'    - same as 'pchip'
%
% See also INTERP1, CHEBFUN/INTERP1, CHEBFUN/SPLINE, CHEBFUN/PCHIP

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Nick Trefethen & Ricardo Pachon,  24/03/2009

if nargin == 4
    switch method
        case []
            % continue
        case 'spline'
            p = spline(xk,yk,d);
            return
        case {'pchip','cubic'}
            p = pchip(xk,yk,d);
            return
        case 'linear'
            p = interpLinear(xk,yk);
            return
        otherwise
            error('CHEBFUN:interp1:method',...
                'Unknown method ''%s''',method);
    end
end
            
% Polynomial interpolation
w = bary_weights(xk);
a = d.ends; 
endpts = a([1 end]);
np = length(xk);
% Loop for quasimatrix support
if min(size(yk))==1
    p = chebfun(@(x) bary(x,yk(:),xk(:),w(:)),endpts,np);
else
    p = chebfun;
    for j = 1:size(yk,2)
        p(:,j) = chebfun(@(x) bary(x,yk(:,j),xk(:),w(:)),endpts,np);
    end
end

function p = interpLinear(xk,y)
% Linear interpolation
n = length(xk);
if size(y,1) ~= length(xk)
    if size(y,2) == length(xk)
        y = y.'; 
    else
        error('CHEBFUN:interp1:liner','Matrix dimensions must agree.');
    end
end
p = chebfun;
for k = 1:size(y,2)
    yk = y(:,k);
    yk = [yk(1:end-1) yk(2:end)].';
    yk = mat2cell(yk,2,ones(1,1,n-1));
    p(:,k) = chebfun(yk,xk);
end


