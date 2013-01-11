function map = maps(varargin)
% MAPS
%  M = MAPS(D) returns the default Chebfun map for the domain D.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% This code is just a wrapper for fun/maps.

map = maps(fun,varargin{:});

