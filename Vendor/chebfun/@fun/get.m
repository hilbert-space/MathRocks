function val = get(g, propName, kind)
% GET Get asset properties from the specified object
% and return the value

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin < 3
    kind = 2;
end

switch propName
    case 'vals'
        if kind == 1
            val = bary(chebpts(g.n,1), g.vals, g.map.for(chebpts(g.n)));
        else
            val = g.vals;
        end
    case 'coeffs'
            val = g.coeffs;       
    case {'points','pts'}
        % Returns mapped Chebyshev points (consistent with vals)
        val = g.map.for(chebpts(g.n,[-1 1],kind));
    case 'n'
        val = g.n;
    case 'scl'
        val = g.scl;
    case 'scl.v'
%         val = g.scl.v;
        val = zeros(numel(g),1);
        for k=1:numel(g)
            val(k) = g(k).scl.v;
        end
    case 'scl.h'
        val = g.scl.h;
    case 'ish'
        val = g.ish;        
    case 'map'
        val = g.map;
    case 'exps'
        val = g.exps;
    case 'lval'  % value at left endpoint
        if g.exps(1) < 0  % inf case, 
            % First try to extract root
            if any(strcmp(g.map.name,{'linear','unbounded'}))
                tmp = extract_roots(g,[],[1 0]);
                if tmp.exps(1) >= 0
                    val = get(tmp,'lval');
                    return
                end
            end
            % If not, then need to check sign
            if g.n > 5 && isinf(g.map.par(1))
                val = inf*sign(mean(g.vals(1:2))+g.vals(1));
            else
                val = inf*sign(g.vals(1));
            end
        elseif g.exps(1) > 0
            val = 0;
        else
            if isempty(g.vals)
                val = NaN;
            elseif all(isfinite(g.map.par(1:2)))
                if ~g.exps(2), val = g.vals(1);
                else           val = g.vals(1)*2^g.exps(2); 
                end
            else
                val = feval(g,g.map.par(1));
            end
        end
    case 'rval' % value at right endpoint 
        if g.exps(2) < 0  % inf case
            % First try to extract root
            if any(strcmp(g.map.name,{'linear','unbounded'}))
                tmp = extract_roots(g,[],[0 1]);
                if tmp.exps(2) >= 0 
                    val = get(tmp,'rval');
                    return
                end
            end
            % If not, then need to check sign
            if g.n > 5 && isinf(g.map.par(2))
                val = inf*sign(mean(g.vals(end-1:end))+g.vals(end));
            else
                val = inf*sign(g.vals(end));
            end
        elseif g.exps(2) > 0
            val = 0;
        else          
            if isempty(g.vals)
                val = NaN;
            elseif all(isfinite(g.map.par(1:2)))
                if ~g.exps(1), val = g.vals(end);
                else           val = g.vals(end)*2^g.exps(1); 
                end
            else
                val = feval(g,g.map.par(2));
            end
        end
    otherwise
        error('FUN:get:propname',[propName,' is not a valid fun property.'])
end