function varargout=gradient(f)
%GRADIENT Numerical gradient of a chebfun2. 
% 
%  [FX FY]=GRADIENT(F) returns the numerical gradient of the chebfun2 F.
%  FX is the derivative of F in the x direction and
%  FY is the derivative of F in the y direction. Both derivatives
%  are returned as chebfun2 objects. 
%
%  G = GRADIENT(F) returns a chebfun2v which represents
% 
%            G = (F_x ; F_y )
%
% See also GRAD.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

fy=diff(f,1,1); fx = diff(f,1,2); 

if ( nargout <= 1 )
    varargout = {chebfun2v(fx,fy)}; 
else
    varargout = {fx,fy};
end

end