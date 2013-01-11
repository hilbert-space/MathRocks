function p = interp1(xk,yk,d)
% INTERP1   Chebfun polynomial interpolant at any distribution of points.
% P = INTERP1(X,F), where X is a vector and F is a chebfun, returns the
% chebfun P defined on domain(F) corresponding to the polynomial
% interpolant through F(X(j)) at points X(j).
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

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Nick Trefethen & Ricardo Pachon,  24/03/2009

w = bary_weights(xk);
a = d.ends; 
endpts = a([1 end]);
np = length(xk);
if min(size(yk))==1
    p = chebfun(@(x) bary(x,yk(:),xk(:),w(:)),endpts,np);
else
    p = chebfun;
    for j = 1:size(yk,2)
        p(:,j) = chebfun(@(x) bary(x,yk(:,j),xk(:),w(:)),endpts,np);
    end
end

