function [edge,vs] = detectedge(f,a,b,hs,vs,der,checkblowup)
% EDGE = DETECTEDGE(F,A,B,HS,VS,DER)
% Edge detection code used in auto.m 
%
% Detects a blowup in first, second, third, or fourth derivatives of 
% F in [A,B].
% HS is the horizontal scale and VS is the vertical scale.
% If no edge is detected, EDGE=[] is returned.
%
% DER is optional and is the derivative of a map (a function handle).
% It is used in the unbounded domain case. If it is not provided, the
% identity map is assumed.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Assume no edge is found
edge = [];

nder = 4; % Number of derivatives to be tested
N = 15;   % grid size for finite difference computations in loop.

% if vertical scale is zero, estimate it (evaluate at arbitrary nodes)
% this may happen in blowup mode
if vs == 0
    xx = [-.85441 ; -0.333331 ; 0.0012 ; 0.2212129 ; 0.766652];
    xx = b*(xx+1)/2+a*(1-xx)/2;
    vs = norm(f(xx),inf);
end

% Interval too small for edge detection, switch to bisection!
if (b-a)^nder < 10*realmin
    return
end

if nargin<6
    der = @(x) 0.*x+1; % Assume identity map!
end

% Compute norm_inf of first nder derivatives. FD grid size is 50.
[na,nb,maxd] = maxder(f, a, b, nder, 50,der);
maxd1 = maxd;
%[na,nb,maxd] = maxder(f, na(nder), nb(nder), nder, N); 

% Keep track of endpoints.
ends = [na(nder) nb(nder)]; 

% Main loop
while maxd(nder) ~= inf && ~isnan(maxd(nder)) &&  diff(ends) > eps*hs
    maxd1 = maxd(1:nder);                                  % Keep track of max derivatives
    [na,nb,maxd] = maxder(f, ends(1), ends(2), nder, N, der);   % compute maximum derivatives and interval
    nder = find( (maxd > (5.5-(1:nder)').*maxd1) & (maxd > 10*vs./hs.^(1:nder)') , 1, 'first' );      % find proper nder
    if isempty(nder)
        return                                          % derivatives are not growing, return edge =[]
    elseif nder == 1 && diff(ends) < 1e-3*hs
        edge = findjump(f, ends(1) ,ends(2), hs, vs, der);  % blow up in first derivative, use findjump
        return
    end
    ends = [na(nder) nb(nder)];
    
    % Blowup mode?
    if checkblowup && abs(f((ends(1)+ends(2))/2)) > 100*vs
        nedge = findblowup(f, ends(1), ends(2) , vs, hs);
        if isempty(nedge)
            checkblowup = false;
        else
            edge = nedge;
            return
        end
    end    
    
end

edge = mean(ends);
%   if any(maxd1 > 1e+15*vs./hs.^(1:length(maxd1))')            % Blowup detected?
%      edge = mean(ends);
%   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edge = findjump(f, a, b, hs, vs, der)
% Detects a blowup in first the derivative and uses bisection to locate the
% edge.

edge = [];                                  % Assume no edge has been found
ya = f(a); yb = f(b);                       % compute values at ends
maxd = abs(ya-yb)/((b-a).*der((b+a)/2));                    % estimate max abs of the derivative
% If derivative is very small, this is probably a false edge
if maxd < 1e-5 * vs/hs
    return
end
cont = 0;                                   % keep track how many times derivative stopped growing
e1 = (b+a)/2;                               % estimate edge location
e0 = e1+1;                                  % force loop

% main loop
% Note that maxd = inf whenever dx < realmin.
while (cont < 2 || maxd == inf) && e0 ~= e1 
    c = (a+b)/2; yc = f(c);                 % find c at the center of the interval [a,b]
    dy1 = abs(yc-ya)/der((a+c)/2); 
    dy2 = abs(yb-yc)/der((b+c)/2);          % find the undivided difference on each side of interval
    maxd1 = maxd;                           % keep track of maximum value
    if dy1 > dy2
       b = c; yb = yc;                      % blow-up seems to be in [a,c]
       maxd = dy1/(b-a);                       % update maxd
    else
       a = c; ya = yc;                      % blow-up seems to be in [c,b]
       maxd = dy2/(b-a);
    end 
    e0 = e1; e1 = (a+b)/2;                  % update edge location. 
    if maxd < maxd1*(1.5), cont = cont + 1; end  % test must fail twice before breaking the loop.
end

if (e0 - e1)<=eps(e0)
   yright = f(b+eps(b));                   % Look at the floting point at the right
   if abs(yright-yb) > eps*100*vs          % if there is a small jump, that is it!
       edge = b;
   else 
       edge = a;
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [na,nb,maxd] = maxder(f,a,b,nder,N,der)
% Compute the norm_inf of derivatives 1:nder

% initial setup
maxd = zeros(nder,1);
na = a*ones(nder,1); nb = b*ones(nder,1);

% generate FD grid points and values
dx = (b-a)/(N-1); 
x = [a+(0:N-2)*dx b].';  
dy = f(x);

% main loop (through derivatives), undivided differences
for j = 1:nder
    dy = diff(dy);
    x = (x(1:end-1)+x(2:end))/2;    
    [maxd(j),ind] = max(abs(dy./der(x)));
    if ind>1,            na(j) = x(ind-1); end
    if ind<length(x)-1,  nb(j) = x(ind+1); end
end
if dx^nder <= eps(0), maxd= inf+maxd; % Avoid divisions by zero!
else maxd = maxd./dx.^(1:nder)';      % get norm_inf of derivatives.
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edge = findblowup(f, a, b , vs, hs)
% Detects blowup location in function values
                                  
ya = abs(f(a)); yb = abs(f(b)); 
y = [ya; yb];
x = [a;b];

while b-a > 1e7*hs
    x = linspace(a,b,50).';
    yy = abs(f(x(2:end-1)));
    y = [ya; yy(:); yb];
    [maxy, ind] = max(abs(y));
    if ind == 1, b = x(3); yb = y(3);
    elseif ind == 50, a = x(48); ya = y(48);
    else
        a = x(ind-1); yb = y(ind-1);
        b = x(ind+1); ya = y(ind+1);
    end
end
while b-a > 50*eps(a) 
    x = linspace(a,b,10).';
    yy = abs(f(x(2:end-1)));
    y = [ya; yy(:); yb];
    [maxy, ind] = max(abs(y));
    if ind == 1, b = x(3); yb = y(3);
    elseif ind == 10, a = x(8); ya = y(8);
    else
        a = x(ind-1); yb = y(ind-1);
        b = x(ind+1); ya = y(ind+1);
    end
end
while b-a >= 4*eps(a)
    x = linspace(a,b,4).';
    yy = abs(f(x(2:end-1)));
    y = [ya; yy(:); yb];
    if y(2) > y(3)
        b = x(3); yb = y(3);
    else
        a = x(2); ya = y(2);
    end    
end

[ymax,ind] = max(y);
edge = x(ind);

if ymax < 1e5*vs
    edge = [];
end
