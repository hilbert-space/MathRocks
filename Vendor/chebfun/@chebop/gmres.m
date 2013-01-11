function varargout = gmres(varargin)
%GMRES Iterative solution of a linear system. 
% U = GMRES(A,F) solves the system A*U=F for chebfuns U and F and linear 
% chebop A. If A is not linear, an error is returned.
%
% More calling options are available; see chebfun/gmres for details.
%
% EXAMPLE:
%
%   % To solve a simple Volterra integral equation:
%   d = [-1,1];
%   f = chebfun('exp(-4*x.^2)',d);
%   A = chebop(@(u) cumsum(u) + 20*u, d);
%   u = gmres(A,f,Inf,1e-14);
%
% See also chebfun/gmres, gmres.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

A = varargin{1};

if ~all(islinear(A))
    error('CHEBOP:gmres','Gmres only supports linear chebops.');
end

op = @(u) A*u;
[varargout{1:nargout}] = gmres(op,varargin{2:end});

end   

