function varargout = plot(varargin)
% A simple plot to graph a mapped FUN on the interval [-1,1].

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

g = varargin{1};
g.exps = [0 0];
y = linspace(-1,1,2001);
x = g.map.for(y);
h = plot(y,feval(g,x),varargin{2:end});

if nargout > 0,
    varargout = h;
end