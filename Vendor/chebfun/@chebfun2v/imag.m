function F = imag(F)
%IMAG imaginary part of a chebfun2v 
% 
% IMAG(F) returns the imaginary part of a chebfun2v.
%
% See also CONJ, REAL.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

%% 
% This could be done more efficiently, but for now we will just call the
% constructor. 

if ( isempty(F.xcheb) || isempty(F.ycheb) )% check for empty chebfun2.
    return;
end

% take real part of each component. 
F.xcheb = imag(F.xcheb); 
F.ycheb = imag(F.ycheb); 
F.zcheb = imag(F.zcheb); 

end