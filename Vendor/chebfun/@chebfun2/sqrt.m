function f = sqrt(f)
%SQRT   Square root.
% 
% SQRT(F) returns the square root chebfun2 of a positive chebfun2 F.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isempty(f.fun2) ) % check for empty chebfun2.
    return;
end 

% positive/negative test. 
[bol wzero] = singlesigntest(f); 

if bol == 0 || wzero == 1
   error('CHEBFUN2:SQRT','A change of sign/zero has been detected, unable to represent the result.'); 
end

% Still call the constructor in case we missed a change of sign. 

op = @(x,y) sqrt(f.feval(x,y)); % resample. 
rect = f.corners;               % Domain. 
f = chebfun2(op,rect);          % Call constructor.

end