function f = extract_roots(f,numroots,sides,tol)
% Extract roots from ends of funs.
% NUMROOTS is total number of roots to extract
% SIDES = [1 0] will extract only from left, [0 1] only
% from the right, and [1 1] from both.
% TOL manually adjusts the tolerance

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin < 2 || isempty(numroots), numroots = inf; end
if nargin < 3 || isempty(sides), sides = [true true]; end

% Get the domain
d = f.map.par(1:2);
infd = isinf(d);

% Get the exponents
exps = get(f,'exps');
f.exps = [0 0];
% Get the map
map = f.map;

% Tolerance for a root
if nargin < 4
    tol = 500*chebfunpref('eps')*f.scl.v;
else
    tol = tol*f.scl.v;
end
f0 = abs(f.vals([1 end]));
f0(~sides) = inf;
% We're a bit more slack at infinite intervals
f0(infd) = 1e-2*f0(infd);

if all(f0 > tol),
    f.exps = exps;
    return
end

% infinite intervals
if any(infd)
    d = [-1 1];
    f.map = linear(d);
    s = map.par(3);
    if all(infd),  rescl = 1./(.5./(5*s));
    else           rescl = 1./(.5./(15*s)); end
else
    rescl = 1;
end
    
num = 0;

if strcmp(map.name,'linear') || strcmp(map.name,'unbounded')
% Linear case is nice
    c = chebpoly(f); % The Chebyshev coefficients of f

    while any(f0 < tol) && f.n >1 && num < numroots
        c = flipud(c);
        if f0(1) < tol
            % left
            a = d(1);   
            sgn = 1;   
            exps(1) = exps(1) + 1;
        else
            % right
            a = d(2);
            sgn = -1;
            exps(2) = exps(2) + 1;
        end
        % Construct the matrix for the recurrence
        n = length(c);
        e = .5*ones(n-1,1);
        D = spdiags([e sgn*2*e e], 0:2, n-1, n-1); 
        D(1,1) = 1;
        % The new coefficients
        c = rescl*sgn*flipud(D\c(2:end));
        % The new values
        vals = chebpolyval(c);
        % Construct new f
        f.vals = vals;
        f.coeffs = c;
        f.n = numel(c);
        % Update f0
        f0 = abs(vals([1 end]));
        f0(~sides) = inf;
        num = num+1;
    end
    
    f.exps = exps;

else
% General finite maps are tricky.   
% Perhaps we can do something similar to the above in the mapped case?
% For now subtract out by force.   
    while any(f0 < tol) && f.n >1 && num < numroots
        if f0(1) < tol && isfinite(d(1))
            % left
            sgn = 1;
            exps(1) = exps(1) + 1;
        elseif isfinite(d(1))
            % right
            sgn = -1;
            exps(2) = exps(2) + 1;
        else
            break
        end
        % Not sure why we need to scale here and not above.
        rescl = diff(d)/2;
        pref = chebfunpref; pref.blowup = 0; %pref.n = f.n; 
        pref.extrapolate = true;
        pref.maxdegree = power(2,round(log2(f.n))+1);
        ftmp = fun(@(x) rescl*newfun(x,f,d,sgn),f.map,pref);
        if ftmp.ish
            f = ftmp;
            f0 = abs(f.vals([1 end]));
            f0(~sides) = inf;
            num = num+1;
        else
            break
        end
    end
    f.exps = exps;
       
end

if ~strcmp(f.map.name,map.name) % we've switched to linear for inf intervals. Switch back.
    f.map = map;
end

function y = newfun(x,f,d,sgn)
    if sgn > 0
        y = feval(f,x)./(x-d(1));
%         y = global_extrapolate(y,sgn);
    else
        y = feval(f,x)./(d(2)-x);
%         y = global_extrapolate(y,sgn);
    end
    
% function y = global_extrapolate(fx,sgn)
%     n = length(fx);
%     if n <= 2, y = fx; return, end
%     e = .5*ones(n,1);
%     D = spdiags([e sgn*2*e e], 0:2, n, n); 
%     D(1,1) = 1;
%     b = D\[zeros(n-3,1) ; -.5 ; 0 ; .5 ];
%     
%     if sgn > 0
%         fx(1) = 0.0;           % step one
%     else
%         fx(end) = 0.0;           % step one
%     end
%     c = chebpoly(chebfun(fx));           % step two
%     alpha = c(1) / b(1);                 % step four
% 
%     c_nm1 = c(2:end).' - alpha*b(2:end); % step five
%     y = chebpolyval([0 ; c_nm1]);

    


