function H = discriminant(f,x,y,varargin)
%DISCRIMINANT the determinant of Hessian of a chebfun2 at (x,y) 
%
% H = DISCRIMINANT(F,x,y) returns the determinant of the Hessian of F at
% (x,y).  The gradient of F should be zero at (x,y). 
% 
% H = DISCRIMINANT(F,G,x,y) returnes the determinant of the 'border' Hessian
% of F at (x,y).
%
% Note that we cannot represent the Hessian matrix because we do not allow
% horizontal concatenation of chebfun2 objects. 
%
% See also JACOBIAN. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(f)
    H=[];
    return
end
% mixed second derivatives.
dfdx2 = diff(f,2,2); dfdy2 = diff(f,2,1); 
dfdxdy = diff(f,[1 1]);
    
    
if nargin == 3   % standard hessian
    % evaluate at (x,y) 
    fxx = feval(dfdx2,x,y);
    fyy = feval(dfdxdy,x,y);
    fxy = feval(dfdy2,x,y);
    
    H = fxx.*fyy - fxy.^2;
elseif nargin == 4  % bordered hessian
    g = x; x = y; y = varargin{1}; 
    % evaluate at (x,y) 
    fxx = feval(dfdx2,x,y);
    fyy = feval(dfdxdy,x,y);
    fxy = feval(dfdy2,x,y);
    
    gx = diff(g,1,2); gy = diff(g,1,1);
    gx = feval(gx,x,y); gy = feval(gy,x,y);
    
    % determinant of bordered hessian.
    H = -gx.*(gx.*fyy-gy.*fxy) + gy.*(gx.*fxy-gy.*fxx);
else
    error('CHEBFUN2:DISCRIMINANT','Invalid input arguments.');
end
    