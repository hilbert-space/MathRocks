function Fout = prod(F)
% PROD   Product integral.
%
% PROD(F) for chebfun F returns exp( sum(log(F)) ).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

Fout = exp(sum(log(F)));