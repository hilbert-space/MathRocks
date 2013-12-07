function v = mean2(f)
%MEAN2 mean of a chebfun2
%
% V = MEAN2(F) returns the mean of a chebfun2: 
% 
%                       d  b
%                      /  /   
%  V = 1/(d-c)/(b-a)   |  |   f(x,y) dx dy 
%                      /  /
%                     c  a
% 
% where the domain of f is [a,b]x[c,d]. 
%
% See also MEAN, STD2.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

rect = f.corners; 
area = (rect(4)-rect(3))*(rect(2)-rect(1)); 
v = integral2(f)/area; 

end