function out = feval(g,x)
% Y = FEVAL(G,X)
% Evaluation of a fun G at points X. In the general case, this is done
% using the barycentric formula in bary.m. However, if X is a vector of Chebyshev
% nodes of length 2^n+1 then the evaluation could be done using FFTs through
% prolong.m (faster).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

exps = g.exps;
ends = g.map.par(1:2);

if isfield(g.map,'inv')
    z = g.map.inv(x);
    
    % Make sure +inf and -inf get mapped to +1 or -1 to avoid NaNs in
    % inverse map
    if any(isinf(g.map.par([1 2])))
        mask = isinf(x); z(mask) = sign(x(mask));
    end
    
    out = bary(z,g.vals);
else
    n = g.n;
    xk = chebpts(n);
    out = bary(x,g.vals,g.map.for(xk));
end

if any(g.exps)
    rescl = (2/diff(ends))^sum(exps);
    
    % hack for unbounded functions on infinite intervals
    if any(isinf(ends))
        s = g.map.par(3);
        if all(isinf(ends))
            rescl = .5/(5*s);
        else
            rescl = .5/(15*s);
        end
        rescl = rescl.^sum(exps);
        ends = [-1 1];   x = g.map.inv(x);
    end

    out = rescl*out.*((x-ends(1)).^exps(1).*(ends(2)-x).^exps(2));
end