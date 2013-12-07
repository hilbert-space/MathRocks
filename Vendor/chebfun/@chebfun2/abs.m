function f = abs(f)
%ABS Absolute value of a chebfun2.
% 
% ABS(F) returns the absolute value of a chebfun2. This function does 
% not work if the function passes through or becomes numerically close to
% zero. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(f.fun2), return; end % check for empty chebfun2.

if ~isreal(f)
   % absolute value of complex-valued function
   g = f.*conj(f);
   f = sqrt(real(g)); 
end

bol = singlesigntest(f);

if bol == 0
   error('CHEBFUN2:ABS','A change of sign has been detected, unable to represent the result.'); 
end

% Still call the constructor in case we missed a change of sign. 
op = @(x,y) abs(f.feval(x,y));  % Resample. 
rect = f.corners;               % Domain.
f = chebfun2(op,rect);          % Call constructor. 

end