function val = integral2(f)
%INTEGRAL2 definite integral of fun2.
% 
% INTEGRAL2(F) returns the definite integral of F. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Could call sum(sum(f)), but below is faster: 
if ( norm(f.U) == 0 )  % If empty fun2. 
    val = 0; 
    return; 
end

rect=getdomain(f);
cvals = mysum(f.C, rect(3:4));     % integrate in y then x. 
rvals = mysum(f.R.', rect(1:2)).'; 
val = (cvals.*(1./f.U))*rvals;

end