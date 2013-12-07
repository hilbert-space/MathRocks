function f = pchip(xk,y)
%PCHIP Chebfun Cubic Hermite Interpolating Polynomial.
%  F = pchip(X,Y) provides a chebfun F on the domain D of the piecewise
%  polynomial form of a certain shape-preserving piecewise cubic Hermite
%  interpolant of the chebfun Y at the sites X. X must be a vector, but Y
%  may be a quasimatrix.
%
%   See also SPLINE, DOMAIN/SPLINE, CHEBFUN/INTERP1

% This is simply a wrapper for @DOMAIN/PCHIP.

yk = feval(y,xk(:));
f = pchip(xk,yk,domain(y));