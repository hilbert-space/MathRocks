function F = conj(F)
%CONJ Complex conjugate of a chebfun2v.
% 
% CONJ(F) returns the complex conjugate of F.  For a complex F, CONJ(F) = 
% REAL(F) - i*IMAG(F). 
%
% See also REAL, IMAG. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.


if ( isempty(F.xcheb) || isempty(F.ycheb) )% check for empty chebfun2.
    return;  % allow third component to be empty. 
end

% take real part of each component. 
F.xcheb = conj(F.xcheb); 
F.ycheb = conj(F.ycheb); 
F.zcheb = conj(F.zcheb); 

end