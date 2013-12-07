function F = transpose(F)
% .'   Transpose
% F.' is the non-conjugate transpose of F.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if numel(F) > 0, trans = not(F(1).trans); end
for k = 1:numel(F)
    F(k).trans = trans; 
end
% F = builtin('transpose',F); % This breaks r2008a, so commenting.
