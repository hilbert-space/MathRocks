function F = minus(F,G)
%- MINUS  Minus of two chebfun2v.  
%
% F - G substracts the chebfun2v F from G componentwise. 
% minus(f,g) is called for the syntax F - G. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.  

F = plus(F,uminus(G));

end