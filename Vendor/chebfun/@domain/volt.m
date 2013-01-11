function V = volt(k,d,onevar)
% VOLT  Volterra integral operator.
% V = VOLT(K,D) constructs a chebop representing the Volterra integral
% operator with kernel K for functions in domain D=[a,b]:
%
%      (V*v)(x) = int( K(x,y) v(y), y=a..x )
%
% The kernel function K(x,y) should be smooth for best results.
%
% K must be defined as a function of two inputs X and Y. These may be
% scalar and vector, or they may be matrices defined by NDGRID to represent
% a tensor product of points in DxD.
%
% VOLT(K,D,'onevar') will avoid calling K with tensor product matrices X
% and Y. Instead, the kernel function K should interpret a call K(x) as
% a vector x defining the tensor product grid. This format allows a
% separable or sparse representation for increased efficiency in
% some cases.
%
% Example:
%
% To solve u(x) + x*int(exp(x-y)*u(y),y=0..x) = f(x):
% d = domain(0,2);
% x = chebfun('x',d);
% V = volt(@(x,y) exp(x-y),d);
% u = (1+diag(x)*V) \ sin(exp(3*x));
%
% See also fred, chebop.

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Default onevar to false
if nargin==2, onevar=false; end

% Operator form - call the chebfun method.
op = @(u) volt(k,u,onevar);

% Make use of the cumsum operator. Note that while C(n) would be triangular
% for low-order quadrature, for spectral methods it is not.
C = cumsum(d);

% Construct the linop
V = linop(@(n)mat(d,k,onevar,C,n),op,d,-1);

% Matrix form. Each row of the result, when taken as an inner product with
% function values, does the proper quadrature.


end

function A = mat(d,k,onevar,C,n)
[n map breaks numints] = tidyInputs(n,d,mfilename);

if isempty(breaks) || isempty(map)
    % Not both maps and breaks
    if ~isempty(map)
        x = map.for(chebpts(n));
    else
        if isempty(breaks), breaks = d.ends; end
        x = chebpts(n,breaks);
    end
else
    % Maps and breaks
    csn = [0 cumsum(n)];
    x = zeros(csn(end),1);
    if iscell(map) && numel(map) == 1, map = map{1}; end
    mp = map;
    for j = 1:numints
        if numel(map) > 1
            if iscell(map), mp = map{j}; end
            if isstruct(map), mp = map(j); end
        end
        ii = csn(j)+(1:n(j));
        x(ii) = mp.for(chebpts(n(j)));
    end
end

if onevar
    A = k(x);
else
    [X,Y] = ndgrid(x);
    A = k(X,Y);
end
A = A.*feval(C,n,0,map,breaks);

end
