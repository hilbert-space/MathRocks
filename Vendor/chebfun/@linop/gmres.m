function varargout = gmres(varargin)
% GMRES Iterative solution of a linear system.
% U = GMRES(A,F) solves the system A*U=F for chebfuns U and F and linop A.
%
% More calling options are available; see chebfun/gmres for details.
%
% EXAMPLE
%
%   % To solve a simple Volterra integral equation:
%   d = domain(-1,1);
%   f = chebfun('exp(-4*x.^2)',d);
%   A = cumsum(d) + 20;
%   u = gmres(A,f,Inf,1e-14);
%
% See also chebfun/gmres, gmres.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

A = varargin{1};
op = @(u) A*u;
[varargout{1:nargout}] = gmres(op,varargin{2:end});

end   

