function varargout = size(A,varargin)
% SIZE   Size.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Same calling options as for built-in size.

[varargout{1:nargout}] = size(A.op,varargin{:});

end