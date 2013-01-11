function [out,i] = min(g)
% MIN	Global minimum on [-1,1]
% MIN(G) is the global minimum of the fun G on [-1,1].
% [Y,X] = MIN(G) returns the value X such that Y = G(X), Y the global minimum.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

[out,i] = max(-g);
out=-out;