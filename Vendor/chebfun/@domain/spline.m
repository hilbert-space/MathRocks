function f = spline(x,y,d)
%SPLINE Chebfun cubic spline data interpolation.
%   F = SPLINE(X,Y,D) provides a chebfun F on the domain D representing
%   the piecewise polynomial form of the cubic spline interpolant to the
%   data values Y at the data sites X. X must be a vector. If Y is a
%   vector, then Y(j) is taken as the value to be matched at X(j), hence Y
%   must be of the same length as X  -- see below for an exception to this.
%   If Y is a matrix, then Y(:,j) is taken as the value to be matched at
%   X(j).
%
%   Ordinarily, the not-a-knot end conditions are used. However, if Y
%   contains two more values than X has entries, then the first and last
%   value in Y are used as the endslopes for the cubic spline..
%
%   Example:
%   This generates a sine-like spline curve and samples it over a finer mesh:
%       x = 0:10;  y = sin(x);
%       f = spline(x,y,domain(0,10));
%       plot(x,y,'o',f)
%
%   See also SPLINE, CHEBFUN/SPLINE, CHEBFUN/INTERP1

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Include breaks defined in the domain
breaks = unique([d.ends x(:).']);

% Number of intervals 
n = numel(breaks)-1;
xx = chebpts(repmat(4,n,1),breaks);

% Forgive some transpose issues
if ~any(size(y,2)==length(x)+[0 2])
    y = y.';
end

% Evaluate using built-in spline
yy = spline(x,y,xx);

% Orientate nicely
if ~any(size(yy,1) == 4*(length(x)+(-1:1))), yy = yy.'; end

% Construct the chebfun
f = chebfun;
for k = 1:size(yy,2)
    data = mat2cell(yy(:,k),repmat(4,n,1),1);
    f(:,k) = chebfun(data,breaks);
end

% Restrict if needed
if d.ends(1) > x(1) || d.ends(end) < x(end)
    f = restrict(f,d);
end
