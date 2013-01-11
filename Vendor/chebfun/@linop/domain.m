function dom = domain(A)
%DOMAIN   Domain of function defintion.
% DOMAIN(A) returns the domain of the functions on which the linop A
% operates, (Note that this isn't quite the "domain of A", which would be
% the space in which the functions it could act upon live).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

dom = A.domain;

end