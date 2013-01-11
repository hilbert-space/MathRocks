function fx = bary(x,gvals,xk,ek)  
% BARY  Barycentric interpolation with arbitrary weights/nodes.
%  P = BARY(X,GVALS,XK,EK) interpolates the values GVALS at nodes 
%  XK in the point X using the barycentric weights EK. 
%
%  P = BARY(X,GVALS) assumes Chebyshev nodes and weights. 
%
%  All inputs should be column vectors.

%  Copyright 2011 by The University of Oxford and The Chebfun Developers. 
%  See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Parse inputs
n = length(gvals);
if n == 1                 % The function is a constant
    fx = gvals*ones(size(x));
    return
end
if any(isnan(gvals))      % The function is NaN
    fx = NaN(size(x));
    return
end
if nargin < 3             % Default to Chebyshev nodes
    xk = chebpts(n);
end
if nargin < 4             % Default to Chebyshev weights
    ek = [.5 ; ones(n-1,1)]; 
    ek(2:2:end) = -1;
    ek(end) = .5*ek(end);
end

% Evaluate the barycentric formula
if length(x) < length(xk) % Loop over evaluation points   
    fx = zeros(size(x));  % Initialise return value
    for i = 1:numel(x)
        xx = ek./(x(i)-xk);
        fx(i) = (xx.'*gvals)/sum(xx);
    end      
else                      % Loop over barycentric nodes
    num = zeros(size(x)); denom = num; % initialise 
    for i = 1:numel(xk)
        y = ek(i)./(x-xk(i));
        num = num+(gvals(i)*y);
        denom = denom+y;
    end
    fx = num./denom;
end

% Clean-up NaNs
for i = find(isnan(fx(:)))'
    indx = find(x(i)==xk,1);
    fx(i) = gvals(indx);
end