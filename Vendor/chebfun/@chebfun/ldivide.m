function h = ldivide(f,g)
% .\	Pointwise chebfun left divide.
%
% F.\G returns a chebfun that represents the function G(x)/F(x). 

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

h = rdivide(g,f);