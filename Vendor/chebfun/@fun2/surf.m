function surf(f,varargin)
%SURF Surface plot of a fun2. 
% 
%  Very basic surf plot for developers. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

minplotnum = 100; % How dense to make the samples. 

% Number of points to plot
j = 1; argin = {};
while ( ~isempty(varargin) )
    if ( strcmpi(varargin{1},'numpts') )
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
surf(xx,yy,vals,argin{1:j-1}); hold on; 
xlabel('x'); ylabel('y');

if ( ~ish )
    hold off 
end
end