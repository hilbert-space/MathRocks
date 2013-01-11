function B = repmat(A,m,n)
% REPMAT   Replicate and tile varmats.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if any([m,n] == 0), B = []; return, end

B = A;
for k = 1:m-1
    B = [B ; A];
end

A = B;
for k = 1:n-1
    B = [B  A];
end

end