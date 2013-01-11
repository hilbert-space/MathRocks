function varargout = semilogy(varargin)
%SEMILOGY Semi-log scale plot.
%   SEMILOGY(...) is the same as PLOT(...), except a
%   logarithmic (base 10) scale is used for the Y-axis.
%
%   See also PLOT, SEMILOGX, LOGLOG.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

h = plot(varargin{:});
set(gca,'YScale','log');

if nargout > 0
    varargout = {h};
end
    
