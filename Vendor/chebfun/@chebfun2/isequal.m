function bol = isequal(f,g)
%ISEQUAL Equality test for chebfun2.  
% 
% BOL = ISEQUAL(F,G) returns 0 or 1. If returns 1 then F and G are the same
% chebfun2, up to relative machine precision. If returns 0 then F and G are
% not the same up to relative machine precision. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

bol=true; % assume they are the same.

if size(f) ~= size(g)
    bol = false;
    return
end

% Are the functions and domains the same?
if ( ~isequal(f.fun2,g.fun2) )
    bol = false;
    return;
end

end