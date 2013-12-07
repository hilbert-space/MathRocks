function f = pchip(x,y,d)
%PCHIP Chebfun Cubic Hermite Interpolating Polynomial.
%  F = pchip(X,Y,D) provides a chebfun F on the domain D of the piecewise
%  polynomial form of a certain shape-preserving piecewise cubic Hermite
%  interpolant, to the values Y at the sites X. X must be a vector. If Y is
%  a vector, then Y(j) is taken as the value to be matched at X(j), hence Y
%  must be of the same length as X. If Y is a matrix, then Y(:,j) is taken
%  as the value to be matched at X(j).
%
%  Example:
%  
%    x = -3:3;
%    y = [-1 -1 -1 0 1 1 1];
%    d = domain(-3,3);
%    plot([pchip(x,y,d) spline(x,y,d)])
%    legend('pchip','spline')
%    hold on, plot(x,y,'or'), hold off
%
%   See also PCHIP, SPLINE, CHEBFUN/PCHIP, CHEBFUN/SPLINE, CHEBFUN/INTERP1

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Include breaks defined in the domain
breaks = unique([d.ends x(:).']);

% Number of intervals 
n = numel(breaks)-1;
xx = chebpts(repmat(4,n,1),breaks);

% Forgive some transpose issues
if ~any(size(y,2)==length(x))
    y = y.';
end

% Evaluate using built-in pchip
yy = pchip(x,y,xx);

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
