function varargout = contour(f,varargin) 
%CONTOUR contour plot of a fun2.
% 
% Basic plotting functions for developers. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

minplotnum = 100; % How dense to make the samples. 

% Number of points to plot
j = 1; argin = {};
while ~isempty(varargin)
    if strcmpi(varargin{1},'numpts')
        minplotnum = varargin{2};
        varargin(1:2) = [];
    else
        argin{j} = varargin{1};
        varargin(1) = [];
        j = j+1;
    end
end

% Get domain.
rect = f.map.for([-1 1],[-1 1]); 
x = linspace(rect(1),rect(2),minplotnum); 
y = linspace(rect(3),rect(4),minplotnum); 
[xx yy]=meshgrid(x,y); 
vals = f.feval(x,y); 


ish = ishold;
h=contour(xx,yy,vals); hold on; 
xlabel('x'); ylabel('y');

if ~ish, hold off, end
if nargout > 0, varargout = {h}; end
end