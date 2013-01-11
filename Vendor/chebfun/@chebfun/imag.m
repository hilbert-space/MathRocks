function Fout = imag(F)
% IMAG   Complex imaginary part.
%
% IMAG(F) is the imaginary part of F.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

Fout = -real(1i*F);