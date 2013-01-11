function varargout = semilogx(varargin)
%SEMILOGX Semi-log scale plot.
%   SEMILOGX(...) is the same as PLOT(...), except a
%   logarithmic (base 10) scale is used for the X-axis.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

h = plot(varargin{:});
set(gca,'XScale','log');

if nargout > 0
    varargout = {h};
end
    