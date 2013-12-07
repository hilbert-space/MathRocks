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

warning('off', 'MATLAB:divideByZero'); % TODO: Delete this.

% Parse inputs
n = length(gvals);
bary1flag = 0;  % If true, possibly use type-1 barycentric formula
if n == 1,                % The function is a constant
    fx = gvals*ones(size(x));
    return
end
if any(isnan(gvals)),     % The function is NaN
    fx = NaN(size(x));
    return
end
if nargin < 3,            % Default to Chebyshev nodes
    bary1flag = 1;
    xk = chebpts(n);
end
if nargin < 4,            % Default to Chebyshev weights
    ek = [.5 ; ones(n-1,1)];
    ek(2:2:end) = -1;
    ek(end) = .5*ek(end);
end
if bary1flag,             % Call a barycentric formula of type 1 or 2
    ind1 = find(imag(x) | x < -1 | x > 1);
    if ~isempty(ind1),
        fx = NaN*x;
        fx(ind1) = kind1(x(ind1),gvals,xk,ek);
        ind2 = find(isnan(fx));
        fx(ind2) = kind2(x(ind2),gvals,xk,ek);
    else
        fx = kind2(x,gvals,xk,ek);
    end
else
    fx = kind2(x,gvals,xk,ek);
end
% Try to clean up NaNs
for i = find(isnan(fx(:)))',
    indx = find(x(i)==xk,1);
    if ~isempty(indx),
        fx(i) = gvals(indx);
    end
end
end



function fx = kind2(x,gvals,xk,ek)
% Evaluate the second-kind barycentric formula. Typically
% this is the standard for evaluating a barycentric interpolant
% on the interval.
if numel(x) < length(xk), % Loop over evaluation points
    fx = zeros(size(x));  % Initialise return value
    for i = 1:numel(x),
        xx = ek ./ (x(i)-xk);
        fx(i) = (xx.'*gvals) / sum(xx);
    end
else                      % Loop over barycentric nodes
    num = zeros(size(x)); denom = num; % initialise
    for i = 1:length(xk),
        y = ek(i) ./ (x-xk(i));
        num = num + (gvals(i)*y);
        denom = denom + y;
    end
    fx = num ./ denom;
end
end



function fx = kind1(x,gvals,xk,ek)
% Evaluate the first-kind barycentric formula. Typically we
% use this formula for evaluating a polynomial outside the interval.
% If the number of nodes is >=600, we compute the log of the
% nodal polynomial in order to avoid under-/ overflow.
% This method is only called with Chebyshev nodes xk on [-1,1]!
n = length(xk);
scale = 2; x = scale*x; xk = scale*xk;
fx = zeros(size(x)); % Initialise return value
if numel(x) < n,     % Loop over evaluation points
    for i = 1:numel(x),
        fx(i) = (ek./(x(i)-xk)).' * gvals;
    end
else                 % Loop over interpolation nodes
    for i = 1:n,
        y = ek(i) ./ (x-xk(i));
        fx = fx + gvals(i)*y;
    end
end
% Evaluate nodal polynomial ell
if n < 600,
    ell = ones(size(x));
    if numel(x) < n, % Loop over evaluation points
        for i = 1:numel(x),
            ell(i) = prod(x(i)-xk);
        end
    else             % Loop over interpolation nodes
        for i = 1:n,
            ell = ell .* (x-xk(i));
        end
    end
else
    ell = zeros(size(x));
    if numel(x) < n, % Loop over evaluation points
        for i = 1:numel(x),
            ell(i) = sum(log(x(i)-xk));
        end
    else             % Loop over interpolation nodes
        for i = 1:n,
            ell = ell + log(x-xk(i));
        end
    end
    ell = exp(ell);
    if isreal(x) && isreal(gvals) && isreal(xk) && isreal(ek),
        ell = real(ell);
    end
end
fx = fx .* ell * (1/(scale*(1-n))*(-2/scale)^(n-2));
end
