function n = normal(c,unit)
%NORMAL the normal to a complex-valued chebfun.
%
% N = NORMAL(C) returns the normal vector to the curve c as a
% quasi-matrix with two columns. The vector has the same magntiude as the 
% curve's tangent vector
%
% N = NORMAL(C,'unit') returns the unit normal vector to the curve c. 
% N is a quasi-matrix with two columns. 
% 
% See also CHEBFUN2V/NORMAL.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

dc = diff(c);
n = -1i*dc; 

if nargin > 1 
    if strcmpi(unit,'unit')
        n = n./norm(n);
    end
else
    error('CHEBFUN:NORMAL','Second argument is not recognised.');
end

n = [real(n) imag(n)];  % return a quasi-matrix. 
 
end