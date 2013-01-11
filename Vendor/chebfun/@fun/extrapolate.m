function g = extrapolate(g,pref,x)
% Extrapolate at endpoints if needed using "Fejer's 2nd rule" type of
% barycentric formula. Also updates the vertical scale of g.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if pref.extrapolate || pref.splitting || any(g.exps) || any(isinf(g.map.par([1 2]))) || any(isnan(g.vals))
    
    if pref.chebkind == 2
        v = g.vals;         % We'll extrapolate the endpoint values, but
        vends = v([1 end]); % put endpoint values back in if they seem right!   
        v = v(2:end-1);     % Below we look for other bad stuff in the interior.
        
        % Obtain Chebyshev points if not given
        if nargin < 3, x = chebpts(g.n); end
        
        % Look for NaN or Inf in the interior
        mask = isnan(v) | isinf(v);
        g.scl.v = max(g.scl.v,norm(v(~mask),inf)); % Update vertical scale
        if any(mask) % Interior NaNs
            if ~isfield(pref,'n') || ~pref.n  % Adaptive
                mask = [true;mask;true];      % Force extrapolation at end points
                xgood = x(~mask);
                if isempty(xgood)
                    error('FUN:extrapolate:nans', ...
                        'Too many nans to handle. Increasing minsamples may help')
                end
                xnan = x(mask);
                w = ones(size(xgood));
                for k = 1:length(xnan)
                    w = w.*abs(xnan(k)-xgood);
                end
                w(2:2:end) = -w(2:2:end);
                for k =1:length(xnan)
                    w2 = w./(xnan(k)-xgood);
                    xnan(k) = sum(w2.*g.vals(~mask))/sum(w2);
                end
                g.vals(mask) = xnan;
                
            else                                    % Non-adaptive
                % In non-adaptive mode, we can't assume we've converged, so
                % we take local interpolants through the 5 nearest neighbours.
                maskends = isnan(g.vals([1 end])) | isinf(g.vals([1 end]));
                mask = [maskends(1) ; mask ; maskends(2)];
                v = [vends(1) ; v ; vends(2)];
                xbad = x(mask); x(mask) = inf;
                for k = 1:sum(mask)
                    [ignored idx] = sort(abs(xbad(k)-x)); % Sort by distance.
                    [idx idx2] = sort(idx(1:5)); % Everybody needs good neightbours.
                    w = bary_weights(x(idx)); % Get weights for this stencil.
                    xbad(k) = bary(xbad(k),v(idx),x(idx),w); % Interpolate.
                    % Sanity check. If the new point is huge, just assign to neighbour.
                    if abs(xbad(k)) > 2*g.scl.v, xbad(k) = v(idx(idx2(1))); end
                end
                g.vals(mask) = xbad;
            end
            
        else        % Force extrapolation at endpoints anyway
            xi = x(2:end-1);
            w = (1+xi); w(2:2:end) = -w(2:2:end);
            g.vals(end) = sum(w.*g.vals(2:end-1))/sum(w);
            w = (1-xi); w(2:2:end) = -w(2:2:end);
            g.vals(1) = sum(w.*g.vals(2:end-1))/sum(w);
        end
        
        % Revert endpoint values?
        if ~isnan(vends(1)) && abs(g.vals(1)-vends(1)) < max(pref.eps,1e3*g.n*eps)*g.scl.v && ...
                ~g.exps(1) && ~isinf(g.map.par(1))
            g.vals(1) = vends(1);
        end
        if ~isnan(vends(2)) && abs(g.vals(end)-vends(2)) < max(pref.eps,1e3*g.n*eps)*g.scl.v && ...
                ~g.exps(2) && ~isinf(g.map.par(2))
            g.vals(end) = vends(end);
        end
        
    else % For first kind points, no need to check endpoints
        
        if any(isnan(g.vals))
            if nargin < 3
                x = chebpts(g.n,pref.chebkind);
            end
            mask = isnan(g.vals) | isinf(g.vals);
            xgood = x(~mask);
            if isempty(xgood)
                error('FUN:extrapolate:nans', ...
                    'Too many nans to handle. Increasing minsamples may help')
            end
            xnan = x(mask);
            
            w = sin((2*(0:g.n-1)+1)*pi/(2*g.n)).';
            w(mask) = [];
            for k=1:length(xnan)
                w =  w.*abs(xnan(k)-xgood);
            end
            w(2:2:end) = - w(2:2:end);
            for k =1:length(xnan)
                w2 = w./(xnan(k)-xgood);
                xnan(k) = sum(w2.*g.vals(~mask))/sum(w2);
            end
            g.vals(mask) = xnan;
        end
        
    end
    
else

    if any(isinf(g.vals))
        error('FUN:extrapolate:inf', ...
            ['Function returned INF when evaluated. ',...
             'You may try using the BLOWUP flag in this case'])
    end
    
end

g.scl.v = max(g.scl.v,norm(g.vals,inf));
    
