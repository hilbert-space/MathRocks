function g = growfun(op,g,pref,g1,g2)
% G = GROWFUN(OP,G,PREF,G1,G2)
%
% G = GROWFUN(OP,G,PREF) returns the fun G representing the function handle OP.
%   PREF is the chebfunpref structure.
%
% G = GROWFUN(OP,G,PREF,G1) returns the fun G representing the composition
%   OP(G1), where G1 is a fun.
%
% G = GROWFUN(OP,G,PREF,G1,G2) returns the fun G representing the composition
%   OP(G1,G2), where G1 and G2 are funs.
%

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Check preferences
split = pref.splitting;
resample = pref.resampling;
extrap = isfield(pref,'extrapolate') && pref.extrapolate;

% Store scale in case not happy. (This is useful for functions which blowup 
% when we don't catch the exponents correctly).
old_scl = g.scl;

% Set minn (minimum number of samples)
minn = pref.minsamples;
% For compositions, this should be at least the length of the input fun
if nargin == 4
    minn = max(minn, g1.n);
elseif nargin == 5
    minn = max([minn, g1.n, g2.n]);   
end
minpower = max(2,ceil(log2(minn-1)));

% Set maxn (the maximum length we'll allow)
if split
    maxn = pref.splitdegree + 1;
else
    maxn = pref.maxdegree + 1;
end
% If maxdegree (maxn-1) is not a power of 2 then with 
% resampling 'off' we oversample and then trim back to maxn.
l2n = log2(maxn-1); oldmaxn = maxn;
if maxn < 2^minpower % We also do this if maxdegree < minsamples.
    l2n = minpower-.1;
    if minn > maxn
        warning('CHEBFUN:fun:growfun:minmax', 'maxdegree was less than minsamples.');
    end
end
if (~resample && l2n ~= round(l2n))
    trimflag = 1;          % Set a flag to tell us to do this.
    maxn = 2.^ceil(l2n)+1;
else
    trimflag = 0;
end
maxpower = max(minpower,floor(log2(maxn-1)));

% Construct vector with number of nodes to be used.
if resample   
    if pref.chebkind == 2
    % With resampling 'on' and Chebyshev points of the second kind, 
    % we take integer powers up to 2^6 (=64), then integer and half-interger
    % powers (i.e. 2^6.5, 2^7, 2^7.5, ...) up to 2^maxpower.
        npn = max(min(maxpower,6),minpower);
        kk = 1 + round(2.^[ (minpower:npn) (2*npn+1:2*maxpower)/2 ]);
        kk = kk + 1 - mod(kk,2);
    else
    % But why don't we do this with 1st kind points?
        kk = 2.^(minpower:maxpower);
    end
else
    if pref.chebkind == 1  
    % Since resampling 'off' will not work with 1st kind points 
    % (because they aren't nested), we force 2nd kind points.
        pref.chebkind = 2;
        warning('FUN:growfun:resampling_kind','In RESAMPLING OFF mode, Chebyshev points of 2nd kind are used')        
    end
    kk = 2.^(minpower:maxpower) + 1;
end

% Set the last entry we try to be the maximum length we allow.
% (This will happen when maxn is not a power of 2).
if kk(end)~=maxn, kk(end+1) = maxn; end

% ---------------------------------------------------
% Composition case: gout = op(g), or gout = op(g1,g2). (see FUN/COMPFUN.M)
if nargin > 3
    % This uses chebpts of 2nd kind!
    g.ish = false;
    pref.sampletest = false;
    if ~resample % Single Sampling
        v = []; ind = 1;
        v1 = get(prolong(g1,kk(ind)),'vals');
        if nargin == 5
            v2 = get(prolong(g2,kk(ind)),'vals');
        end
        if extrap && ~pref.splitting
        % Avoid evaluating at ends if is extrapolation is forced.
        %  (Although we can't do this if splitting is on.)
            v1([1 end]) = v1([2 end-1]); 
            if nargin == 5
                v2([1 end]) = v2([2 end-1]); 
            end
        end
        if nargin == 5
            vnew = op(v1,v2);
        else
            vnew = op(v1);
        end
        % Loop over the vector of lengths
        while ind <= numel(kk)
            % Update v (which stores the vals at the Chebyshev points)
            if isempty(v)
                v = vnew;
            else
                v(1:2:kk(ind)) = v;
                v(2:2:end-1) = vnew;
            end
            g = set(g,'vals', v);               % Set the values (and vscl)
            g = extrapolate(g,pref);            % Extrapolate if need be
            g = ishappy(op,g,pref);       % Test happiness
            if g.ish, break, end                  % We're happy. Quit.
            if ind == length(kk), break, end    % We've failed. Quit.
            
            % New vals
            ind = ind + 1;
            v1 = get(prolong(g1,kk(ind)),'vals');
            v1 = v1(2:2:end-1);
            if nargin == 5
                v2 = get(prolong(g2,kk(ind)),'vals');
                v2 = v2(2:2:end-1);
                vnew = op(v1,v2);  
            else
                vnew = op(v1);  
            end
        end
    else % Double sampling
        for k = kk
            v1 = get(prolong(g1,k),'vals');
            if nargin == 5
                v2 = get(prolong(g2,k),'vals');
                if extrap
                    v = op(v1(2:k-1),v2(2:k-1));
                    v = [NaN ; v(:) ; NaN];
                else
                    v = op(v1,v2);
                end
            else
                if extrap
                    v = op(v1(2:k-1));
                    v = [NaN ; v(:) ; NaN];
                else
                    v = op(v1);
                end
            end
            g = set(g,'vals', v);               % Set the values (and vscl)
            g = extrapolate(g,pref);            % Extrapolate if need be       
            g = ishappy(op,g,pref);       % Test happiness
            if g.ish, break, end                  % We're happy. Quit.
        end
    end
            
    % Original maxn was wasn't a power of 2, so trim g back.
    if trimflag && g.n > oldmaxn
        g = prolong(g,oldmaxn);
        if g.ish, g.ishh = ishappy(op,g,pref); end  % Check happiness again
    end
    
    return

end
% ---------------------------------------------------

map = g.map;
% Catch horizontal scale for unbounded intervals.
ab = map.par(1:2);% The endpoints.
adapt = false;
if any(isinf(ab))
    adapt = mappref('adaptinf');
    if ~adapt
        a = ab(1); b = ab(2);
        if all(isinf(ab))
            g.scl.h = max(abs(diff(map.par(3:4))),abs(sum(map.par(3:4))));
        elseif a == -inf
            g.scl.h = max(abs(b), abs(b - map.par(3)));
        else
            g.scl.h = max(abs(a), abs(a + map.par(3)));
        end
    end
end

if ~resample && ~adapt     % SINGLE SAMPLING
    % Initialise
    ind = 1; v = [];
    x = chebpts(kk(ind));
    xvals = map.for(x);   
    if isfield(pref,'extrapolate') && pref.extrapolate && ~pref.splitting
    % Avoid evaluating at ends if is extrapolation is forced.
    % Although we can't do this if splitting is on.
        xvals([1 end]) = xvals([2 end-1]); 
    end
    vnew = op(xvals);
    % Loop over the vector of lengths
    while kk(ind)<=kk(end)
        % Update v (which stores the vals at the Chebyshev points)
        if isempty(v)
            v = vnew;
        else
            v(1:2:kk(ind)) = v;
            v(2:2:end-1) = vnew;
        end
        % Update g
        g = set(g,'vals', v);               % Set the values (and vscl)
        g.coeffs = [];
        g = extrapolate(g,pref,x);          % Extrapolate if need be
        g = ishappy(op,g,pref);      % Check for happiness
        if g.ish || ind == length(kk), break, end % Either happy, or failed.
        % New points and vals
        ind = ind + 1;
        x = chebpts(kk(ind),pref.chebkind);
        xvals = map.for(x(2:2:end-1));
        vnew = op(xvals);            
    end   

    % Original maxn was wasn't a power of 2, so trim g back.
    if trimflag && g.n > oldmaxn     % (This rarely happens)
        g = prolong(g,oldmaxn);
        if g.ish, g = ishappy(op,g,pref); end  % Check happiness again
    end
    
else                      % DOUBLE SAMPLING
    % This is usually wasteful, but sometimes necessary (as in chebops).
    for k = kk
        if adapt % Adaptive infinite intervals
            [map,v,hscl] = unbounded(g.map.par, op, k);
            g.vals = v; g.n = k; % Don't update v scale!
            g.map = map;
            g = extrapolate(g,pref);
            g.scl.h = hscl;
        else     % Standard case
            x = chebpts(k,pref.chebkind);
            xvals = map.for(x);
            if extrap
                vals = op(xvals(2:k-1));
                g = set(g,'vals',[NaN ; vals(:) ; NaN]);
                g = extrapolate(g,pref,x);
            else
                g = set(g,'vals',op(xvals));
                g = extrapolate(g,pref,x);
            end
        end
        g = ishappy(op,g,pref);
        if g.ish
            if isfield(pref,'simplify') && ~pref.simplify
                g = prolong(g,k);
            end
            break
        end
    end
    
end

% Check for Inf's
if isinf(g.scl.v)
    if ~pref.blowup
        error('FUN:growfun:inf_blowup', ...
            'Function returned Inf when evaluated. Have you tried ''blowup on''?')
    elseif ~split
        error('FUN:growfun:inf_split', ...
            'Function returned Inf when evaluated. Have you tried ''splitting on''?')
    else
        g.ish = false;
        % The function blows up on this interval. We revert the vertical scale 
        % so that we can try to catch this next time with splitting and blowup.
        g.scl = old_scl;
        return
    end
    
end
% Check for NaN's
if any(isnan(g.vals))
% Extrapolate should have already dealt with NaNs. If we reach here, there's a problem.    
    error('FUN:growfun:naneval','Function returned NaN when evaluated.')
end
if ~g.ish && pref.blowup
    % If not happy, then we revert the scale (as the respresentation may change 
    % when using exponents).
    g.scl = old_scl;
end

%-------------------------------------------------------------------------
function  g = ishappy(op,g,pref)
% ISHAPPY happiness test for funs
%   [ISH,G2] = ISHAPPY(OP,G,X,PREF) tests if the fun G is a good approximation 
%   to the function handle OP. ISH is either true or false. If ISH is true,
%   G2 is the simplified version of G. PREF is the chebfunpref structure.

% Calling the constructor with a 'scale' option overrides that from scl.v
if isfield(pref,'scale')
    g.scl.v = max(g.scl.v,pref.scale);
end

g.coeffs = [];
n = g.n;                                        % Original length
g = simplify(g,pref.eps,pref.chebkind);   % Attempt to simplify

% Antialiasing procedure ('sampletest')
if g.ish && pref.sampletest 
    x = chebpts(g.n); % Points of 2nd kind (simplify returns vals at 2nd kind points)
    vals = g.vals;
    if g.n == 1
        xeval = 0.61; % Pseduo-random test value
    else
        % Test a point where the (finite difference) gradient of g is largest
        [ignored indx] = max(abs(diff(vals))./diff(x));
        xeval = (x(indx+1)+1.41*x(indx))/(2.41);
    end
    map = g.map.for;
    v = op(map(xeval)); 
    if norm(v-bary(xeval,vals,x),inf) > max(pref.eps,1e3*eps)*g.n*g.scl.v
    % If the fun evaluation differs from the op evaluation, sample test failed.
        g.ish =  false;
    end
end