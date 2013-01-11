function g = newdomain(g,ends)
%NEWDOMAIN fun change of domain
% NEWDOMAIN(G,DOM) returns the fun G but moved to the interval DOM. This is 
% done with a linear map. 

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

map = g.map;
if isa(ends,'domain'), ends = ends.ends; end

% endpoints!
a = map.par(1); b = map.par(2); 
c = ends(1); d = ends(end);

if a == c && b == c
    % Nothing to do here.
    return
elseif d < c
    error('FUN:newdomain:negdom','Invalid domain [%f,%f].',a,b);
end

if strcmp(map.name,'linear')
    if ~any(isinf([c d]))
        % composition of linear maps is linear (because they're, umm, linear!)
        map = linear(ends);
    else
        map = maps(domain(c,d));
        if ~all([a b]==[-1 1])
            error('FUN:newdomain:suck', ...
                'No support for this finite to unbounded domain change');
            % IDEA! First combine with linear map from [a b] to [-1 1].
        end
        if g.n > 1
            warning('FUN:newdomain:nonlin',...
                'using a nonlinear map for a nonlinear function.');
        end
    end
elseif any(isinf([a b]))
    if any(isinf([a b]-[c d]))
        error('FUN:newdomain:infdom','Inconsistent unbounded domains.');
    end
    if isinf(d)
        map.for = @(y) map.for(y) - a + c;
        map.inv = @(x) map.inv(x - c + a);
        map.par(1:2) = ends;
    elseif isinf(c)
        map.for = @(y) map.for(y) - b + d;
        map.inv = @(x) map.inv(x - d + b);
        map.par(1:2) = ends;
    end 
else
    % linear map from [a b] to [c d]
    linfor = @(y) ((d-c)*y+c*(b-a)-a*(d-c))/(b-a);
    lininv = @(x) ((b-a)*x+a*(d-c)-c*(b-a))/(d-c);
    der = (d-c)/(b-a);

    % new composed map
    map.for = @(y) linfor(map.for(y));
    map.inv = @(x) map.inv(lininv(x));
    map.der = @(y) der*map.der(y);
    map.par(1:2) = ends;
end

% update fun!
g.map = map;
g.scl.h = max(g.scl.h,norm(ends,inf));