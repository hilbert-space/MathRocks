function dom = domain(N)
%DOMAIN   Domain of function definition.
% DOMAIN(N) returns the domain of the functions on which the chebop N
% operates, (Note that this isn't quite the "domain of N", which would be
% the space in which the functions it could act upon live).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

dom = N.domain;

end