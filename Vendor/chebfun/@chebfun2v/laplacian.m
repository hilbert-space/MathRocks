function L = laplacian(F)
%LAPLACIAN Vector Laplacian of a chebfun2v.
%
% L = LAPLACIAN(F) returns a chebfun2v representing the vector 
% Laplacian of F. 
%
% See also CHEBFUN2V/LAP.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% check for an empty chebfun2v object. 
if isempty(F)
    L = chebfun2v;
    return; 
end

L = F; 

L.xcheb = laplacian(F.xcheb); 
L.ycheb= laplacian(F.ycheb); 

if ~isempty(F.zcheb)
   L.zcheb= laplacian(F.zcheb); 
end

end