function D = diff(d,m)
% DIFF Differentiation operator.
% D = DIFF(R) returns a chebop representing differentiation for chebfuns
% defined on the domain R.
%
% D = DIFF(R,M) returns the chebop for M-fold differentiation.
%
% See also chebop, linop, chebfun/diff.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin == 1, m = 1; end

if round(m)~=m
    error('CHEBFUN:domain:diff:fracdiff',...
        'Fractional derivatives are not yet supported as operators.');
end

if m == 0
    D = eye(d);
elseif isempty(d)
    D = linop;
    return
elseif all(isfinite(d.ends))
    D = linop( @(n) mat(d,n,m), @(u) diff(u,m), d, m );   
else
    D = linop( @(n) mat(d,n,1), @(u) diff(u), d, 1 );
    if m > 1, D = mpower(D,m); end
end

end

function D = mat(d,n,m)
[n map breaks numints] = tidyInputs(n,d,mfilename);

if isempty(map) && isempty(breaks)
    % Standard case
    D = diffmat(n,m)*(2/length(d))^m;
elseif isempty(breaks)
    % Map / no breakpoints
    if isstruct(map)
        if m == 1 && isfield(map,'der') && ~isempty(map.der)
            D = diag(1./map.der(chebpts(n)))*diffmat(n);
        else
            D = barydiffmat(map.for(chebpts(n)),[],m);
        end
    else
        D = barydiffmat(map(chebpts(n)),[],m);
    end
elseif isempty(map)
    % Breakpoints / no maps
    csn = [0 cumsum(n)];
    D = zeros(csn(end));
    for k = 1:numints
        ii = csn(k)+(1:n(k));
        D(ii,ii) = diffmat(n(k),m)*(2/diff(breaks(k:k+1)))^m;
    end
else
    % Breaks and maps
    numints = numel(breaks)-1;
    csn = [0 cumsum(n)];
    D = zeros(csn(end));
    if iscell(map) && numel(map) == 1
        map = map{1};
    end
    mp = map;
    for k = 1:numints
        if numel(map) > 1
            if iscell(map), mp = map{k}; end
            if isstruct(map), mp = map(k); end
        end
        ii = csn(k)+(1:n(k));
        if m == 1 && isfield(mp,'der') && ~isempty(mp.der)
            D(ii,ii) = diag(1./mp.der(chebpts(n(k))))*diffmat(n(k));
        else
            D(ii,ii) = barydiffmat(mp.for(chebpts(n(k))),[],m);
        end
    end
end
end


function Dk = barydiffmat(x,w,k)  
% BARYDIFFMAT  Barycentric differentiation matrix with arbitrary weights/nodes.
%  D = BARYDIFFMAT(X,W) creates the first-order differentiation matrix with
%       nodes X and weights W.
%
%  D = BARYDIFFMAT(X) assumes Chebyshev weights. 
%
%  DK = BARYDIFFMAT(X,W,K) returns the differentiation matrice of DK of order K.
%
%  All inputs should be column vectors.
%
%  See http://www.maths.ox.ac.uk/chebfun for chebfun information.

%  Copyright 2002-2009 by The Chebfun Team. 
%  Last commit: $Author: hale $: $Rev: 1285 $:
%  $Date: 2010-11-22 16:09:51 +0000 (Mon, 22 Nov 2010) $:

N = length(x)-1;
if N == 0
    N = x;
    x = chebpts(N);
end

if nargin == 2 && length(w)-1~=N
    if length(w) == 1
        k = w; 
        w = [];
    else
        error('DOMAIN:diff:barydiffmat:lengthin',['Length of weights vector ', ...
        'must match length of points.']);
    end
end

if nargin < 2 || isempty(w) % Default to Chebyshev weights
    w = [.5 ; ones(N,1)]; 
    w(2:2:end) = -1;
    w(end) = .5*w(end);
end

if nargin < 3, k = 1; end

ii = (1:N+2:(N+1)^2)';
Dx = bsxfun(@minus,x,x');   % all pairwise differences
Dx(ii) = Dx(ii) + 1;        % add identity
Dw = bsxfun(@rdivide,w.',w);
Dw(ii) = Dw(ii) - 1;        % subtract identity

% k = 1
Dk = Dw ./ Dx;
Dk(ii) = 0; Dk(ii) = - sum(Dk,2);
if k == 1, return; end
% k = 2
Dk = 2*Dk .* (repmat(Dk(ii),1,N+1) - 1./Dx);
Dk(ii) = 0; Dk(ii) = - sum(Dk,2);
% higher orders
for j = 3:k
    Dk = j./Dx .* (Dw.*repmat(Dk(ii),1,N+1) - Dk);
    Dk(ii) = 0; Dk(ii) = - sum(Dk,2);
end

end


