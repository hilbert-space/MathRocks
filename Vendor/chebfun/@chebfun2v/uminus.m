function f = uminus(f)
%- Unary minus of a chebfun2v
% 
% -F returns the chebfun2v negated componentwise. 
% UMINUS(F) is called by the syntax -F. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

f.xcheb = uminus(f.xcheb);
f.ycheb = uminus(f.ycheb);
f.zcheb = uminus(f.zcheb);

end