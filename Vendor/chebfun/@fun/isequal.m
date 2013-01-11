function out = isequal(g1,g2)
% ISEQUAL True if funs are equal.
%    ISEQUAL(A,B) returns logical 1 (TRUE) if fund G1 and G2 are the same
%    length, contain the same values, have the same map, and the same exponents.
%    Logical 0 (FALSE) is returned otherwise.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if g1.n==g2.n && all(g1.vals==g2.vals) && samemap(g1,g2) && all(g1.exps == g2.exps)
    out = true;
else
    out = false;
end