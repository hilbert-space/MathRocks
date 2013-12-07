function F = real(F)
%REAL  real part of a chebfun2v.
%
% REAL(F), returns the chebfun2v representing the real part.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isempty(F.xcheb) || isempty(F.ycheb) )% check for empty chebfun2.
    return;
end

% take real part of each component. 
F.xcheb = real(F.xcheb); 
F.ycheb = real(F.ycheb); 
F.zcheb = real(F.zcheb); 

end