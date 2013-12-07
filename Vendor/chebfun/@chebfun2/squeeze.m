function g = squeeze(f)
%SQUEEZE  squeeze a chebfun2 to one variable, if possible.
% 
% G = squeeze(F) returns a chebfun2 if F depends on x and y. If F depends
% only on the x-variable a row chebfun is returned and if it depends on
% just the y-variable a column chebfun is returned. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 


tol = chebfun2pref('eps'); rect = f.corners;

% Check if the function f is empty. 
if ( isempty(f) )
   g = f; % return empty chebfun2.  
   return
end


if ( length(f) == 1 )
    C = f.fun2.C; R=f.fun2.R; U = f.fun2.U; % col, row and pivots
    if ( norm(C(:,1)-C(1,1)) < 10*tol )
        g = C(1,1)*U*R; id =1;
    elseif ( norm(R(1,:)-R(1,1)) < 10*tol )
        g = C*U*R(1,1); id=3;
    else
        g = f;
    end
    if ( isa(g,'double') )
        g = chebfun(g,[rect(id),rect(id+1)]);
    end
else
    g = f;
end

if ( isa(g,'chebfun') )
    g = simplify(g);
end

end