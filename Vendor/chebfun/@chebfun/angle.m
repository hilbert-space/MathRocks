function p = angle(h)
% ANGLE  Chebfun phase angle.
%
% ANGLE(H) returns the phase angles, in radians, of a complex-valued 
% chebfun or quasi-matrix.
%
% See also ANGLE, CHEBFUN/ABS, CHEBFUN/UNWRAP.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

p = atan2(imag(h), real(h));

for k = 1:numel(h)
    p(k).jacobian = anon('error; der = error; nonConst = ~der2.iszero;',{'p'},{p(k)},1,'angle');
    p(k).ID = newIDnum();
end