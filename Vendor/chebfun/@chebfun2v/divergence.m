function f = divergence(f)
%DIVERGENCE the divergence of a chebfun2v.
%
% F = DIVERGENCE(F) returns the divergence of the chebfun2v i.e. 
% 
%  divergence(F) = F_x + F_y

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

% Note that divergence of a 3-vector is the same, because the functions are
% of two variables.
f = diff(f.xcheb,1,2) + diff(f.ycheb,1,1);  % divergence.

end