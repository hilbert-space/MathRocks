function f = minus(f,g)
%- MINUS  subtraction for fun2.
%
% F-G subtracts the fun2 F by G. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

f = plus(f,uminus(g));

end