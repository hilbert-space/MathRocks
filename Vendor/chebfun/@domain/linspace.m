function x = linspace(d,varargin)
% LINSPACE Linearly spaced points in a domain. 
% LINSPACE(D,M) returns a vector of M points linearly spaced in the domain
% D. If omitted, M defaults to 100.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(d)
  x = [];
else
  x = linspace(d.ends(1),d.ends(end),varargin{:});
end

end