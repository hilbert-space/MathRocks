function spy(S,varargin)
%SPY Visualize sparsity pattern.
%  SPY(S) plots the sparsity pattern of the linear chebop S.
%
%  SPY(S,C) uses the color given by C.
%
%  Example:
%    N = chebop(@(x,u,v) [diff(u), diff(v,2) + u]);
%    spy(N,'m')

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

S = linop(S);

spy(S,varargin{:})
