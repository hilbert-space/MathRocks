function f = spline(xk,y,v)
%SPLINE Chebfun cubic spline data interpolation.
%   F = SPLINE(X,Y) provides a chebfun piecewise polynomial cubic spline
%   interpolant F to the chebfun Y the data sites X. X must be a vector,
%   but F may be a quasimatrix.
%
%   Ordinarily, the not-a-knot end conditions are used. However, the call 
%   F = SPLINE(X,Y,V) will use the values in V([1 2],:) as the endslopes 
%   at Y.ends(1) and Y.ends(end) respectively. V should be a vector of size
%   2 x numel(F).
%
%   Example:
%   This generates a sine-like spline curve and samples it over a finer mesh:
%       x = 0:10;  y = chebfun(@sin,[0 10]);
%       f = spline(x,y);
%       plot(x,y(x),'o',f)
%
%   See also SPLINE, DOMAIN/SPLINE, CHEBFUN/INTERP1

% This is simply a wrapper for @DOMAIN/SPLINE.

yk = feval(y,xk(:));
if nargin == 3
    if size(v,2)~=size(yk,2), v = v.'; end
    yk = [v(1,:) ; yk ; v(2,:)];
end
f = spline(xk,yk,domain(y));
