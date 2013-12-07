function isReal=isreal(f)
%ISREAL Real-valued chebfun2 test.
%
% ISREAL(F) returns logical true if F does not have an imaginary part
% and false otherwise.
%  
% ~ISREAL(F) detects chebfun2s that have an imaginary part even if
% it is all zero.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

fun = f.fun2;   % assume real at the start.

% For F to be real we make sure everything is real (otherwise roundoff 
% would make the function imaginary). 

isReal = isreal(get(fun,'U')) && isreal(get(fun,'C')) && ...
                                         isreal(get(fun,'R')) ;

end
