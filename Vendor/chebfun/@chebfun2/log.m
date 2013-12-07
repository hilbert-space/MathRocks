function f = log(f)
%LOG Natural logarithm of a chebfun2.
% 
% LOG(F) is the natural logarithm of F. This function does not
% work if the function passes through or becomes numerically close to
% zero. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(f) % check for empty chebfun2.
    return; 
end 

% positive/negative test. 
[bol wzero] = singlesigntest(f); 

if bol == 0 || wzero == 1
   error('CHEBFUN2:LOG','A change of sign/zero has been detected, unable to represent the result.'); 
end

% Still call the constructor in case we missed a change of sign. 
op = @(x,y) log(f.feval(x,y));  % Resample. 
rect = f.corners;               % Domain.
f = chebfun2(op,rect);          % Call constructor. 

end