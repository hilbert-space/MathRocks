function g = simplify(g,tol,kind,force)
% This function removes leading Chebyshev coefficients that are below 
% epsilon, relative to the verical scale stored in g.scl.v

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.


% Recurse?
if numel(g) > 1
    for k=1:numel(g)
        if nargin < 2
            g(k) = simplify(g(k));
        elseif nargin < 3
            g(k) = simplify(g(k),tol);
        elseif nargin < 4
            g(k) = simplify(g(k),tol,kind);
        else
            g(k) = simplify(g(k),tol,kind,force);
        end
    end
    return;
end

% Assume we're happy!
g.ish = true;

gn = g.n;
% Deal with the trivial case
if gn < 2  % (Can't be simpler than a constant!)
    if isempty(g.coeffs), g.coeffs = g.vals; end
    return
end

% Get the defaults
if nargin == 1
    tol = chebfunpref('eps');
end
if nargin < 3 || isempty(kind)
    kind = 2; % Second kind is default
end
epstol = eps(1);

% Check the vertical scale
scl = g.scl;
if scl.v == 0, 
    % Check for NaN's or Inf's
    if any(isnan(g.vals))
        error('FUN:simplify:naneval',...
            'Function returned NaN or Inf when evaluated.')
    end
    % g is the zero function
    g.n = 1; g.vals = 0; g.coeffs = 0;
    return
elseif any(isinf(scl.v))
    % Inf located: try blowup?!
    g.ish = false;
    return
end

% Get the coefficients
c = chebpoly(g,kind);                  % Coeffs of Cheb expansion of g
ac = abs(c)/scl.v;                     % Abs value relative to scale of g

% NaNs are not allowed
if any(isnan(ac))
    error('FUN:simplify:NaNEval', 'Function returned NaN when evaluated.')
end

% Force simplification to a tolerance
if nargin == 4 && force == 1
    c = c(find(ac > tol,1):end);       % Chop the tail 
    v = chebpolyval(c,2);              % Values at 2nd kind points
    if length(v) > 1 && kind == 2
        % Force interpolation at endpoints
        g.vals = [g.vals(1);v(2:end-1);g.vals(end)];              
    else
        g.vals = v;
    end
    g.n = length(v);
    g.coeffs = c;
    return
end

Tlen = min(g.n,max(5,round((gn-1)/8))); % Length of tail to test
% Which basically is the same as:
%  Tlen = n,             for n = 1:3
%  Tlen = 3,             for n = 4:25
%  Tlen = round((n-1)/8) for n > 25

% LNT's choice --------------------------------------
% Tmax = 2e-16*Tlen^(2/3);              % maximum permitted size of tail
% ---------------------------------------------------

% RodP's choice -------------------------------------
if kind == 2
    m = gn-1; xpts = sin(pi*(-m:2:m)/(2*m)).';  % Chebyshev points
else
    m = gn-1; xpts = sin(pi*(-m:2:m)/(2*m+2)).';% 1st-kind Chebyshev points
end
xpts = g.map.for(xpts);
df = max(diff(xpts),eps*scl.h);
mdiff =  (scl.h/scl.v)*norm(diff(g.vals)./df,inf);
% Choose maximum between prescribed tolerance and estimated rounding errors
Tmax = max(tol,epstol*min(1e12,max(mdiff,Tlen^(2/3)))); % Max size of tail
% ---------------------------------------------------

% Check for convergence and chop
if max(ac(1:Tlen)) < Tmax               % We have converged; now chop tail
    Tend = find(ac>=Tmax,1,'first')-1;  % Pos of first entry above Tmax
    
    % Is g the zero function? 
    if isempty(Tend)                   
        % g is the zero function
        g.n = 1; g.vals = 0; g.coeffs = 0;
        return
    end

    ac = ac(1:Tend);                     % Restrict to coeffs of interest
    ac(1) = .225*tol;                    % <-- Why do we do this?   
    for k = 2:Tend                       % Compute the cumulative max of
        ac(k) = max(ac(k),ac(k-1));      %    the tail entries and .225*tol
    end
    Tbpb = log(1000*Tmax./ac)./ ...
        (length(c)-(1:Tend)');           % Bang/buck of chopping at each pos
    [ignored Tchop] = max(Tbpb(3:Tend)); % Tchop = pos at which to chop
    c = c(Tchop+3:end);                  % Chop the tail
    v = chebpolyval(c,2);                % Values at 2nd kind points                                        
                                        
%     % Ensure an odd number of points?
%     if mod(length(c(Tchop+3:end)),2) == 0 % == 1 or even?
%         c = c(Tchop+2:end);              % Chop the tail
%     else
%         c = c(Tchop+3:end);
%     end
%     v = chebpolyval(c,2);                % Values at 2nd kind points                            
                                                                          
    % Update values
    if length(v) > 1 && kind == 2
        % force interpolation at endpoints
        g.vals = [g.vals(1); v(2:end-1); g.vals(end)];              
    else
        g.vals = v;
    end
    g.n = length(v);
    
else
    % We're not happy. :(
    g.ish = 0;
end

% Update coefficients
g.coeffs = c;

