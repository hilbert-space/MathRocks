function f = conj(f)
%CONJ Complex conjugate of a chebfun2.
% 
% CONJ(F) returns the complex conjugate of F.  For a complex F, CONJ(F) = 
% REAL(F) - i*IMAG(F). 
%
% See also REAL, IMAG. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% This function could be done without calling the constructor, but since we
% expect this function will not be used much we will just call the
% constructor for now. 

if ( isempty(f) )  % check for empty chebfun2. 
   return;
end

op = @(x,y) conj(f.feval(x,y));  % Resample. 
rect = f.corners;                % Domain.
f = chebfun2(op,rect);           % Call constructor. 

end