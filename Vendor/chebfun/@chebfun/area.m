function varargout = area(f,varargin)
% AREA    Filled chebfun area plot.
%
% See also area chebfun/plot

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Parse the chebfun input
if isempty(f)
    varargout = {};
    return
end

% Get the (x,y) data from plotdata.m
numpts = chebfunpref('plot_numpts');
lines = plotdata([],f,[],numpts);

% Remove NaNs from jumps
x = lines{1}; y = lines{2};
mask = find(isnan(y));
y(mask) = (y(mask+1)+y(mask-1))/2;

% Call built-in area.m
h = area(x,y,varargin{:});

% Output h if asked for
if nargout > 0
    varargout = {h};
end
