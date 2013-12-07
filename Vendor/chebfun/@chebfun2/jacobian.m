function J = jacobian(f,g)
%JACOBIAN Jacobian determinant of two chebfun2.
%
% J = JACOBIAN(F,G) returns the Jacobian determinant of the Jacobian
% matrix. 
%
% Note we return the determinant of the Jacobian matrix and not the
% Jacobian matrix itself. 
%
% See also CHEBFUN2V/JACOBIAN. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isempty(f) || isempty(g) )  % empty check. 
    J=[]; 
    return; 
end

% call chebfun2v/jacobian.
J = jacobian([f;g]);

end