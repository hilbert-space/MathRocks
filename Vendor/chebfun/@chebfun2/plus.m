function h = plus ( f, g )
%+	  Plus.
%
% F + G adds chebfun2s F and G, or a scalar to a chebfun2 if either F or G
% is a scalar.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(f) || isempty(g)  % check for empty chebfun2
   h = chebfun2;  % just return an empty chebfun2. 
   return; 
end

% quick check for zero chebfun2 objects. 
if ( isa(f,'chebfun2') && norm(f.fun2.U) == 0 ) 
    h = g; return;
end

if ( isa(g,'chebfun2') && norm(g.fun2.U) == 0 ) 
    h = f; return;
end



if ( isa(f,'chebfun2') && isa(g,'double') )  
%% chebfun2 + double
    if isempty(f) % check for empty chebfun2.
        return
    end
    h = f;
    h.scl = f.scl;
    h.fun2 = plus(f.fun2,g);
elseif ( isa(f,'double') && isa(g,'chebfun2') )  
%% double + chebfun2
    if isempty(g) % check for empty chebfun2.
        return
    end
    h = g;
    h.scl = g.scl;
    h.fun2 = plus(f,g.fun2);
elseif ( isa(f,'chebfun2') && isa(g,'chebfun2') )  
%% chebfun2 + chebfun2
    if isempty(g) % check for empty chebfun2.
        h = f; return
    end
    if isempty(f) % check for empty chebfun2.
        h = g; return
    end
    h = f;
    h.fun2 = plus(f.fun2,g.fun2);
    h.scl = h.fun2.scl;
else
    error('CHEBFUN2:plus:type','Cannot add these two objects together');
end

end