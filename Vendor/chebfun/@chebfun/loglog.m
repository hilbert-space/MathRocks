function varargout = loglog(varargin)
% LOGLOG   Log-log scale plot.
%
% LOGLOG(...) is the same as PLOT(...), except logarithmic scales are used 
% for both the X- and Y- axes.
%
% See also PLOT, SEMILOGX, SEMILOGY.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

h = plot(varargin{:});
set(gca,'XScale','log','YScale','log');

if nargout > 0
    varargout = {h};
end
    