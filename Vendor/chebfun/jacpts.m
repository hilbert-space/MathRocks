function [x,w,v] = jacpts(n,alpha,beta,varargin)
%JACPTS  Gauss-Jacobi Abscissae and Quadrature Weights.
%  X = JACPTS(N,ALPHA,BETA) returns the N roots of the degree N Jacobi 
%       polynomial with parameters ALPHA and BETA (which must both be 
%       greater than or equal -1)
%
%  [X,W] = JACPTS(N,ALPHA,BETA) returns also a row vector W of weights for 
%       Gauss-Jacobi quadrature.
%
%  [X,W,V] = JACPTS(N,ALPHA,BETA) returns additionally a column vector V of 
%       weights in the barycentric formula corresponding to the points X.
%
%  [X,W,V] = JACPTS(N,ALPHA,BETA,METHOD) allows choice in which method is used.
%       METHOD = 'GW' will use the traditional Golub-Welsch eigenvalue method,
%       which is best suited for when N is small. METHOD = 'FAST' will use 
%       the Glaser-Liu-Rokhlin fast algorithm, which is much faster for large N.
%       By default JACPTS will use 'GW' when N < 128.
%
%  [X,W,V] = JACPTS(N,ALPHA,BETA,[A,B]) scales the nodes and weights for the 
%       finite interval [A,B].
%
%  The cases ALPHA = BETA = -.5 and ALPHA = BETA = .5 correspond to
%  Gauss-Chebyshev nodes and quadrature, and are treated specially 
%  (as a closed form of the nodes and weights is available). 
%  ALPHA = BETA = 0 calls LEGPTS, which is a more efficient code.
%
%  See also legpts and chebpts.

%  Copyright 2011 by The University of Oxford and The Chebfun Developers. 
%  See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

%  'FAST' by Nick Hale, April 2009 - algorithm adapted from [1].
%
%  References:
%   [1] A. Glaser, X. Liu and V. Rokhlin, "A fast algorithm for the 
%       calculation of the roots of special functions", SIAM Journal  
%       on Scientific Computing", 29(4):1420-1438:, 2007.


% Defaults
interval = [-1,1];
method = 'default';

if n < 0
    error('CHEBFUN:jacpts:n','First input should be a positive number.');
end

% Return empty vector if n == 0
if n == 0
    x = []; w = []; v = []; return
end

if alpha <= -1 || beta <= -1,
    error('CHEBFUN:jacpts:SizeAB','alpha and beta must be greater than -1')
end
a = alpha; b = beta;

% check inputs
if nargin > 3
    if isa(varargin{1},'double') && length(varargin{1}) == 2
        interval = varargin{1};
    elseif isa(varargin{1},'domain')
        interval = varargin{1}.ends;
    elseif isa(varargin{1},'char')
        method = varargin{1}; 
    end
    if length(varargin) == 2,
        if isa(varargin{2},'double') && length(varargin{2}) == 2
            interval = varargin{2};
        elseif isa(varargin{1},'domain')
            interval = varargin{2}.ends;
        elseif isa(varargin{2},'char')
            method = varargin{2}; 
        end
    end
end

if nargout > 1 && any(isinf(interval)) % infinite intervals not yet supported
                                       % (How do we scale the weights?) 
    error('CHEBFUN:jacpts:infinterval', ...
    'jacpts does not yet support infinite intervals');
end

% % Special cases
% Legendre: alpha = beta = 0
if ~(a || b) % The case alpha = beta = 0 is treated by legpts
    [x w v] = legpts(n,varargin{:});
    return
end
% Gauss-Chebyshev: alpha = beta = -.5
if a == -.5 && b == -.5
    [x ignored v] = chebpts(n,interval,1);
    w = repmat(pi/n,1,n);
    return
end
% Gauss-Chebyshev2:  alpha = beta = .5
if a == .5 && b == .5
    x = chebpts(n+2,2);     x = x(2:n+1);
    w = pi/(n+1)*(1-x.^2);  w = w';
    if nargout == 3, v = (1-x.^2);  v(2:2:end) = -v(2:2:end); end
    [x w] = rescale(x,w,interval,alpha,beta);
    return
end

% Fix n == 1 case for GW
if n == 1, method = 'fast'; end

% decide to use GW or FAST
if (n < 128 || strcmpi(method,'GW')) && ~strcmpi(method,'fast')
    ab = a + b;
    ii = (2:n-1)';
    abi = 2*ii + ab;
    aa = [(b - a)/(2 + ab) ; (b^2 - a^2)./((abi - 2).*abi) ; (b^2 - a^2)./((2*n - 2+ab).*(2*n+ab))];
    bb = [2*sqrt( (1 + a)*(1 + b)/(ab + 3))/(ab + 2) ; 
        2*sqrt(ii.*(ii + a).*(ii + b).*(ii + ab)./(abi.^2 - 1))./abi];
    TT = diag(bb,1) + diag(aa) + diag(bb,-1); % Jacobi matrix
    [V x] = eig( TT );                        % Eigenvalue decomposition
    x = diag(x);                              % Jacobi points
    w = V(1,:).^2*( 2^(ab + 1) * gamma(a + 1) * gamma(b + 1) / gamma(2 + ab) ); % Quadrature weights
    v = sqrt(1-x.^2).*abs(V(1,:))';           % Barycentric weights
    v = v./max(v); v(2:2:n) = -v(2:2:end); 
else   % Fast, see [2]
   [x ders] = alg0_Jac(n,a,b);                % Nodes and P_n'(x)
   w = 1./((1-x.^2).*ders.^2)';               % Quadrature weights
   if a && b                                  % Get the right constant
       C = 2^(a+b+1)*gamma(2+a)*gamma(2+b)/(gamma(2+a+b)*(a+1)*(b+1));
       w = C*w/sum(w);
   else
       w = 2^(a+b+1)*w;
   end
   v = 1./ders; v = v./max(abs(v));           % Barycentric weights
   if ~mod(n,2), v = -v;   end
end

[x w] = rescale(x,w,interval,alpha,beta);

function [x w] = rescale(x,w,interval,alpha,beta)
% rescale to arbitrary interval
if all(interval == [-1 1])
    % Nothing to do
    return
end

if ~any(isinf(interval))
    % finite interval
    c1 = .5*sum(interval); 
    c2 = .5*diff(interval);
    w = c2^(alpha+beta+1)*w;
    x = c1+c2*x;        
else
    % infinite interval (not yet supported)
    m = maps(fun,{'unbounded'},interval); % use default map
    if nargout > 1
        w = w.*m.der(x.');
    end
    x = m.for(x);
    x([1 end]) = interval([1 end]);
end


function [roots ders] = alg0_Jac(n,a,b)
if abs(a)<=.5 && abs(b)<=.5 % use asymptotic formula
    r = ceil(n/2); % Choose a root near the middle
    C = (2*r+a-.5)*pi/(2*n+a+b+1);
    T = C + 1/(2*n+a+b+1)^2*((.25-a^2)*cot(.5*C)-(.25-b^2)*tan(.5*C));
    x1 = cos(T);
    
    % Make accurate using Newton
    [u up] = eval_Jac(x1,n,a,b);
	while abs(u) > eps
        x1 = x1 - u/up;
        [u up] = eval_Jac(x1,n,a,b);      
    end
    
    if n == 1, roots = x1; ders = up; return, end

    [rootsl dersl] = alg1_Jac_as(n,x1,up,a,b,1); % Get roots to the left
    if a ~= b 
        [rootsr dersr] = alg1_Jac_as(n,x1,up,a,b,0); % To the right
    else
        rootsr = -rootsl; % Use symmetry.
        dersr = dersl;
        if rootsl(1) > 0, rootsl(1) = []; dersl(1) = []; end
    end
    
    roots = [rootsl(end:-1:2) ; rootsr];
    ders = [dersl(end:-1:2) ; dersr];
else

%    % Attempt 1: Starts at the left and works through
%     [x1 up] = alg3_Jac(n,1-eps,a,b) ;
%     d1 = up;
%     if n == 1, roots = x1; ders = up; return, end   
%     if n > 1 % Get the 2nd root
%         % Initial guess
%         x2 = rk2_Jac(pi/2,-pi/2,x1,n,a,b);
%         % Make accurate using Newton
%         [u up] = eval_Jac(x2,n,a,b);
%         while abs(u) > eps
%             x2 = x2 - u/up;
%             [u up] = eval_Jac(x2,n,a,b);      
%         end
%     
%         if a ~= b 
%             [roots ders] = alg1_Jac(n,x2,up,a,b,1);
%             roots = [x1 ; roots];
%             ders = [d1 ; ders];
%         else
%             [roots ders] = alg1_Jac(n,x2,up,a,b,0);
%             roots = [x1 ; roots ; -roots((end-mod(n,2):-1:1)) ; x1];
%             ders = [d1 ; ders ; ders((end-mod(n,2):-1:1)) ; d1];
%         end
%     end

%    % Attempt 2: Starts at the middle (more accurate)
    [x1 up] = alg3_Jac(n,0,a,b);
    
    if n == 1, roots = x1; ders = up; return, end
    
   [rootsl dersl] = alg1_Jac(n,x1,up,a,b,1); % Get roots to the left
    if a ~= b 
        [rootsr dersr] = alg1_Jac(n,x1,up,a,b,0); % To the right
    else
        rootsr = -rootsl(1+mod(n,2):end); % Use symmetry.
        dersr = dersl(1+mod(n,2):end);
        if rootsl(1) > 0, rootsl(1) = []; dersl(1) = []; end
    end
    
    roots = [rootsl(end:-1:2) ; rootsr];    
    ders = [dersl(end:-1:2) ; dersr];
end


% ---------------------------------------------------------------------

function [roots ders] = alg1_Jac(n,x1,up,a,b,flag)
ab = a + b;
% if flag, N = n-2; else N = ceil(n/2)-2; end
if flag, sgn = -1; else sgn = 1; end
N = n-1;
roots = [x1 ; zeros(N,1)]; ders = [up ; zeros(N,1)];
m = 30; % number of terms in Taylor expansion
hh1 = ones(m+1,1); u = zeros(1,m+1); up = zeros(1,m+1);
for j = 1:N
    x = roots(j);
    h = rk2_Jac(sgn*pi/2,-sgn*pi/2,x,n,a,b) - x;
    
    if abs(x+h) > 1, roots(j+1:end) = []; ders(j+1:end) = []; return, end
    
    % scaling
    M = 1/h;

    % recurrence relation  (scaled)
    u(1) = 0;   u(2) = ders(j)/M;  up(1) = u(2); up(m+1) = 0;    
    for k = 0:m-2
        u(k+3) = ((x*(2*k+ab+2)+a-b)*u(k+2)/M + ...
            (k*(k+ab+1)-n*(n+ab+1))*u(k+1)/M^2/(k+1))./((1-x.^2)*(k+2));
        up(k+2) = (k+2)*u(k+3)*M;
    end
    
    % flip for more accuracy in inner product calculation
    u = u(m+1:-1:1);
    up = up(m+1:-1:1);
    
    % Newton iteration
	hh = hh1; hh(end) = M;    step = inf;  l = 0; 
    while (abs(step) > eps) && (l < 10)
        l = l + 1;
        step = (u*hh)/(up*hh);
        h = h - step;
        hh = [M;cumprod(M*h+zeros(m,1))]; % powers of h (This is the fastest way!)
        hh = hh(end:-1:1);
    end
    
    
    if abs(h) < eps, roots(j+1:end) = []; ders(j+1:end) = []; return, end
    
    % update
    roots(j+1) = x + h;
    ders(j+1) = up*hh;   
end

% -------------------------------------------------------------------------

function [roots ders] = alg1_Jac_as(n,x1,up,a,b,flag) % if |a|<=.5 && |b|<=.5 use asymptotic formula
ab = a + b;

% Approximate roots via asymptotic formula
nx1 = ceil(n/2);
if flag, r = (nx1+1):n; else r = (nx1-1):-1:1; end
C = (2*r+a-.5)*pi/(2*n+ab+1);
T = C + 1/(2*n+a+b+1)^2*((.25-a^2)*cot(.5*C)-(.25-b^2)*tan(.5*C));
roots = [x1 ; cos(T).']; ders = [up ; zeros(length(T),1)];

m = 30; % number of terms in Taylor expansion
hh1 = ones(m+1,1); u = zeros(1,m+1); up = zeros(1,m+1);
for j = 1:length(r)
    x = roots(j); % previous root
    
    % initial approx (via asymptotic foruma)
    h = roots(j+1) - x;
           
    % scaling
    M = 1/h;

    % recurrence relation for Jacobi polynomials (scaled)
    cx = (1-x.^2);
    u(1) = 0;   u(2) = ders(j)/M;  up(1) = u(2); up(m+1) = 0;    
    for k = 0:m-2
        u(k+3) = ((x*(2*k+ab+2)+a-b)*u(k+2)/M + ...
            (k*(k+ab+1)-n*(n+ab+1))*u(k+1)/M^2/(k+1))./(cx*(k+2));
        up(k+2) = (k+2)*u(k+3)*M;
    end
    
    % flip for more accuracy in inner product calculation
    u = u(m+1:-1:1);  up = up(m+1:-1:1);
    
    % Newton iteration
    hh = hh1; hh(end) = M;    step = inf;  l = 0; 
    while (abs(step) > eps) && (l < 10)
        l = l + 1;
        step = (u*hh)/(up*hh);
        h = h - step;
        hh = [M;cumprod(M*h+zeros(m,1))]; % powers of h (This is the fastest way!)
        hh = hh(end:-1:1); % flip for more accuracy in inner product calculation
    end

    % update
    roots(j+1) = x + h;
    ders(j+1) = up*hh;    
end

% ---------------------------------------------------------------------

function [x1 d1] = alg3_Jac(n,xs,a,b)
[u up] = eval_Jac(xs,n,a,b);
theta = atan((1-xs.^2)*up/sqrt(n*(n+a+b+1)*(1-xs.^2))/u);
x1 = rk2_Jac(theta,-pi/2,xs,n,a,b);

for k = 1:10
    [u up] = eval_Jac(x1,n,a,b);
    x1 = x1 - u/up;
end

[u1 d1] = eval_Jac(x1,n,a,b);

% -------------------------------------------------------------------------

function [P Pp] = eval_Jac(x,n,a,b)
ab = a + b;

P = .5*(a-b+(ab+2)*x);  Pm1 = 1; 
Pp = .5*(ab+2);         Ppm1 = 0; 

if n == 0;
    P = Pm1; Pp = Ppm1;
end

for k = 1:n-1
    A = 2*(k+1)*(k+ab+1)*(2*k+ab);
    B = (2*k+ab+1)*(a^2-b^2);
    C = prod(2*k+ab+(0:2)');
    D = 2*(k+a)*(k+b)*(2*k+ab+2);
    
    Pa1 = ( (B+C*x).*P - D*Pm1 ) / A;
    Ppa1 = ( (B+C*x).*Pp + C*P - D*Ppm1 ) / A;
    
    Pm1 = P; P = Pa1;  Ppm1 =  Pp; Pp = Ppa1;
end

% -------------------------------------------------------------------------

function x = rk2_Jac(t,tn,x,n,a,b)
ab = a + b;
m = 10; h = (tn-t)/m;
for j = 1:m
    f1 = (1-x.^2);
    k1 = -4*h*f1./(4*sqrt(n*(n+ab+1)*f1) + (b-a-(ab+1)*x).*sin(2*t));
    t = t+h;
    f2 = (1-(x+k1).^2);
    k2 = -4*h*f2./(4*sqrt(n*(n+ab+1)*f2) + (b-a-(ab+1)*(x+k1)).*sin(2*t));
    x = x+.5*real(k1+k2);
end


