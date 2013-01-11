function out = isinf(d)
% ISINF   True for unbounded domains.
%  ISINF(D) returns a 2x1 array which is true if that end of the domain is 
%  infinite, and false if not.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

out = isinf(d.ends);