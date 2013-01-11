function F = cumprod(F)
% CUMPROD   Indefinite product integral.
%
% CUMPROD(F) is the indefinite product integral of the chebfun F, which 
% is defined as exp( cumsum(log(F)) ).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

F = exp(cumsum(log(F)));
