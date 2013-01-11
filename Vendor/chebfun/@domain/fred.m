function F = fred(k,d,onevar)
% FRED  Fredholm integral operator.
% F = FRED(K,D) constructs a chebop representing the Fredholm integral
% operator with kernel K for functions in domain D=[a,b]:
%    
%      (F*v)(x) = int( K(x,y)*v(y), y=a..b )
%  
% The kernel function K(x,y) should be smooth for best results.
%
% K must be defined as a function of two inputs X and Y. These may be
% scalar and vector, or they may be matrices defined by NDGRID to represent
% a tensor product of points in DxD. 
%
% FRED(K,D,'onevar') will avoid calling K with tensor product matrices X 
% and Y. Instead, the kernel function K should interpret a call K(x) as 
% a vector x defining the tensor product grid. This format allows a 
% separable or sparse representation for increased efficiency in
% some cases.
%
% Example:
%
% To solve u(x) - x*int(exp(x-y)*u(y),y=0..2) = f(x), in a way that 
% exploits exp(x-y)=exp(x)*exp(-y), first write:
%
%   function K = kernel(X,Y)
%   if nargin==1   % tensor product call
%     K = exp(X)*exp(-X');   % vector outer product
%   else  % normal call
%     K = exp(X-Y);
%   end
%
% At the prompt:
%
% d = domain(0,2);
% x = chebfun('x',d);
% F = fred(@kernel,d);  % slow way
% tic, u = (1-diag(x)*F) \ sin(exp(3*x)); toc
%   %(Elapsed time is 0.265166 seconds.)
% F = fred(@kernel,d,'onevar');  % fast way
% tic, u = (1-diag(x)*F) \ sin(exp(3*x)); toc
%   %(Elapsed time is 0.205714 seconds.)
%
% See also volt, chebop.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Default onevar to false
if nargin==2, onevar=false; end    

% Operator form - call the chebfun method.
op = @(u) fred(k,u,onevar);

% Construct the linop
F = linop(@(n)mat(d,k,onevar,n),op,d);

end

% Matrix form. At given n, multiply function values by CC quadrature
% weights, then apply kernel as inner products.
function A = mat(d,k,onevar,n)
[n map breaks numints] = tidyInputs(n,d,mfilename);

if isempty(breaks) || isempty(map)
    % Not both maps and breaks
    if ~isempty(map)
        [x s] = chebpts(n);
        s = map.der(x.').*s;
        x = map.for(x);
    else
        if isempty(breaks), breaks = d.ends; end
        [x s] = chebpts(n,breaks);
        n = sum(n);
    end
else
    % Maps and breaks
    csn = [0 cumsum(n)];
    x = zeros(csn(end),1);
    s = zeros(1,csn(end));
    if iscell(map) && numel(map) == 1, map = map{1}; end
    mp = map;
    for j = 1:numints
        if numel(map) > 1
            if iscell(map), mp = map{j}; end
            if isstruct(map), mp = map(j); end
        end
        ii = csn(j)+(1:n(j));
        [xj sj] = chebpts(n(j));
        s(ii) = mp.der(xj.').*sj;
        x(ii) = mp.for(xj);
    end
    n = sum(n);
end

if onevar  % experimental
    A = k(x)*spdiags(s',0,n,n);
else
    [X,Y] = ndgrid(x);
    A = k(X,Y) * spdiags(s',0,n,n);
end

end