function f = imag(f)
%IMAG imaginary part of a chebfun2 
% 
% IMAG(F) returns the imaginary part of a chebfun2.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

%% 
% This could be done more efficiently, but for now we will just call the
% constructor. 

if isempty(f) % check for empty chebfun2.
    return;
end

op = @(x,y) imag(f.feval(x,y));  % Resample. 
rect = f.corners;                % Domain.
f = chebfun2(op,rect);           % Call constructor. 

end