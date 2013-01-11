function out = std(f)
% STD	Standard deviation.
% STD(F) is the standard deviation of the chebfun F.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

out = sqrt(var(f));