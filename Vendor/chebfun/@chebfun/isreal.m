function isr=isreal(F)
% ISREAL Real-valued chebfun test.
%
% ISREAL(F) returns logical true if F does not have an imaginary part
% and false otherwise.
%  
% ~ISREAL(F) detects chebfuns that have an imaginary part even if
% it is all zero.
%   
% See also CHEBFUN/REAL, CHEBFUN/IMAG.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

isr = true;
for k = 1:numel(F)
    isr = isr && isreal(get(F(k),'vals'));
    isr = isr && isreal(F(k).imps);
    if ~isr
        break;
    end
end