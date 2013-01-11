function p = interp1(xk,f)
% INTERP1   Chebfun polynomial interpolant at any distribution of points.
% 
%  P = INTERP1(X,F), where X is a vector and F is a chebfun, returns the
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
% on [-1,1] through a hat function:
%
% EXAMPLE:
%   x = chebfun('x');
%   f = max(0,1-2*abs(x));
%   x = linspace(-1,1,11);
%   p = interp1(x,f)
%   plot(f,'k',p,'r',x,f(x),'.r'), grid on

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% This is simply a wrapper for @DOMAIN/INTERP1.

yk = feval(f,xk);
p = interp1(xk,yk,domain(f));
