function [out,idx] = max(g)
% MAX	Global maximum on [-1,1]
% MAX(G) is the global maximum of the fun G on [-1,1].
% [Y,X] = MAX(G) returns the value X such that Y = G(X), Y the global maximum.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if (g.exps(1) < 0 && g.vals(1) >= 0) 
    out = inf; 
    idx = g.ends(1);
    return
end

if (g.exps(2) < 0 && g.vals(end) >= 0) 
    out = inf;
    idx = g.ends(end);
    return
end

r = roots(diff(g));
ends = g.map.par(1:2);
r = [ends(1);r;ends(end)];
[out,idx] = max(feval(g,r));
idx = r(idx);

% Take the max of the computed max and the function values.
if ~any(g.exps)
    [vmax, vidx] = max(g.vals);
    if vmax > out
        out = vmax;
        x = get(g,'points');
        idx = x(vidx);
    end
end