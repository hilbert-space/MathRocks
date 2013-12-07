function v = norm(F)
%NORM Frobenius norm of a chebfun2v
%
% V = NORM(F) returns the Frobenius norm of the two/three components, i.e. 
% 
%    V = sqrt(norm(F1).^2 + norm(F2).^2),
%
% or
% 
%    V = sqrt(norm(F1).^2 + norm(F2).^2 + norm(F3).^2) 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

if isempty(F.zcheb) 
    v = sqrt(norm(F.xcheb).^2 + norm(F.ycheb).^2);
else
    v = sqrt(norm(F.xcheb).^2 + norm(F.ycheb).^2 + norm(F.zcheb).^2);
end

end