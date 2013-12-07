function J = jacobian(F)
%JACOBIAN Jacobian determinant of a chebfun2v.
%
% J = JACOBIAN(F) computes the determinant of the Jacobian matrix
% associated to the vector-valued chebfun2v F. The chebfun2v must have two
% components. 
%
% Note we return the determinant of the Jacobian matrix and not the
% Jacobian matrix itself. 
%
% See also CHEBFUN2/GRADIENT. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isempty(F) )  % empty check. 
    J=[]; 
    return; 
end


if ( ~isempty(F.zcheb) )
    error('CHEBFUN2V:JACOBIAN','Jacobian matrix is not square.')
end

% Determinant formula: 
dudx = diff(F.xcheb,1,2); dudy = diff(F.xcheb); 
dvdx = diff(F.ycheb,1,2); dvdy = diff(F.ycheb); 

J = dudx.*dvdy - dudy.*dvdx; 

end
