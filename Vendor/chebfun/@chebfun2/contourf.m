function varargout = contourf(f,varargin)
%CONTOURF Filled contour plot of a chebfun2.
%
% CONTOURF(...) is the same as CONTOUR(...) except that the areas
% between contours are filled with colors according to the Z-value
% for each level.  Contour regions with data values at or above a
% given level are filled with the color that maps to the interval.
%
% NaN's in the Z-data leave white holes with black borders in the
% contour plot.
%
% When you use the CONTOUR(Z, V) syntax to specify a vector of contour
% levels (V must increase monotonically), contour regions with
% Z-values less than V(1) are not filled (are rendered in white).
% To fill such regions with a color, make V(1) less than or equal to
% the minimum Z-data value.
%
% CONTOURF(F,'NUMPTS',N) computes the contour lines on a N by N grid. If N
%     is larger than 200 then the contour lines are drawn with more detail.
%
% [C, H] = CONTOURF(...) also returns a handle H to a CONTOURGROUP object.
%
% See also CONTOUR.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

doWeHoldOn = ishold;
minplotnum = 200; % How dense to make the samples.
rect = f.corners;

% Number of points to plot
j = 1; argin = {};
while ~isempty(varargin)
    if strcmpi(varargin{1},'numpts') % Get numpts if given them.
        minplotnum = varargin{2};
        varargin(1:2) = [];
    else
        argin{j} = varargin{1};
        varargin(1) = [];
        j = j+1;
    end
end

% Plot using matlab contourf.
x = linspace(rect(1),rect(2),minplotnum);
y = linspace(rect(3),rect(4),minplotnum);
[xx yy]=meshgrid(x,y);vals = f.feval(xx,yy);
[c h]=contourf(xx,yy,vals,argin{:});

if ( ~doWeHoldOn )
    hold off
end

% Return plot handle if appropriate.
if ( nargout > 0 )
    varargout = {h};
end
if ( nargout > 1 )
    varargout = {c,h};
end
end