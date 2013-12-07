function varargout = cylinder(r)
%CYLINDER Generate cylinder.
%
%   [X, Y, Z] = CYLINDER(R) forms the unit cylinder based revolving the 
%   function R about the z-axis. X, Y, and Z are chebfun2 objects such that
%   surf(X,Y,Z) displays the cylinder. 
%
%   F = CYLINDER(R) constructs the chebfun2v that represents the surface of
%   revolution. SURF(F) displays the cylinder.
%
%   Omitting output arguments causes the cylinder to be displayed with a SURF
%   command and no outputs are returned.

% Copyright 2013 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Convert r to discrete values:
ends = r.ends;

d = [ends 0 2*pi];

f = chebfun2(@(x,y) feval(r,x), d); 
u = chebfun2(@(u,v) u, d);
v = chebfun2(@(u,v) v, d);

F = [f.*sin(v); f.*cos(v); u];  % surface of revolution.

if ( nargout == 0 )
    surf(F);  % plot
elseif ( nargout == 1 )
    % return chebfun2v
    varargout = {F}; 
else
    varargout = {F(1), F(2), F(3)};  % return as a parameterisation. 
end

end
