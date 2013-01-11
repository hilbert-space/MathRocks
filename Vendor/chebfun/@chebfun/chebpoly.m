function out = chebpoly(f,varargin)
% CHEBPOLY   Chebyshev polynomial coefficients
% 
% A = CHEBPOLY(F) returns the vector of coefficients such that
% F_1 = A(1) T_M(x) + ... + A(M) T_1(x) + A(M+1) T_0(x), where T_M(x) denotes 
% the M-th Chebyshev polynomial and F_1 denotes the first fun of chebfun F.
%
% A = CHEBPOLY(F,I) returns the coefficients for the I-th fun.
%
% A = CHEBPOLY(F,I,N) truncates or pads the vector A so that N coefficients 
% of the fun F_I are returned. However, if I is 0 then the global coefficients 
% of the *chebfun* F are returned (by computing relevent inner products with 
% Chebyshev polynomials).
%
% C = CHEBPOLY(F,...,'kind',2) returns the vector of coefficients for the 
% Chebyshev expansion of F in 2nd-kind Chebyshev polynomials
% F_1 = C(1) U_M(x) + ... + C(M) U_1(x) + C(M+1) U_0(x)
%
% There is also a CHEBPOLY command in the chebfun trunk directory, which
% computes the chebfun corresponding to the Chebyshev polynomial T_n.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

argin = {}; ii = []; N = [];
kind = 1;
while ~isempty(varargin)
    if any(strcmpi(varargin{1},{'chebkind','kind'}))
        kind = varargin{2};
        varargin(1:2) = [];
    else
        argin = [argin varargin{1}];
        varargin(1) = [];
    end
end
if numel(argin) > 0, ii = argin{1}; end
if numel(argin) > 1, N = argin{2}; end
       
if numel(f) > 1, 
    error('CHEBFUN:chebpoly:quasi','CHEBPOLY does not handle chebfun quasi-matrices.')
end
if isempty(ii) 
    if f.nfuns > 1
        warning('CHEBFUN:chebpoly:nfuns1',['Chebfun has more than one fun. Only the Chebyshev' ...
                 ' coefficients of the first one are returned.' ...
                 ' Use CHEBPOLY(F,1) to suppress this warning.']);
    end
    ii = 1; 
end
if ii > f.nfuns
    error('CHEBFUN:chebpoly:nfuns2',['Chebfun only has ',num2str(f.nfuns),' funs.']);
end
if numel(ii) > 1 || numel(N) > 1
    error('CHEBFUN:chebpoly:scalar','Inputs I and N must be scalars.');
end
if ii == 0 && isempty(N)
    error('CHEBFUN:chebpoly:inputs','Input N must not be empty if I is zero.');
end
if ~isempty(N) && ~isnumeric(N)
    error('CHEBFUN:chebpoly:inputN','Input N must be a scalar.');
end
% No truncating or padding. So just default behavior.
if isempty(N)
    out = chebpoly(f.funs(ii)).';
    if kind == 2 && numel(out) > 1
        out(end) = 2*out(end);
        out = .5*[out(1:2) out(3:end)-out(1:end-2)];
    end
    return
end

% Truncating or padding of a fun. Also deals with simple, linear chebfun case.
if ii > 0 || (f.nfuns == 1 && ~any(f.funs(1).exps) && strcmp(f.funs(1).map.name,'linear'))
    if ii == 0, ii = 1; end
    c = chebpoly(f.funs(ii)).';
    c = [zeros(1,N-length(c)) c];
    out = c(end-(N-1):end);
    
    if kind == 2 && numel(out) > 1
        out(end) = 2*out(end);
        out = .5*[out(1:2) out(3:end)-out(1:end-2)];
    end
    return
end

% Compute coefficients via inner products.
d = [f.ends(1),f.ends(end)];
x = chebfun('x',d);

if any(isinf(d))
    error('CHEBFUN:chebpoly:infint','Infinite intervals are not supported here.');
else
    w = 1./sqrt((x-d(1)).*(d(2)-x));
    out = zeros(1,N);
    for k = 1:N
        T = chebpoly(k-1,d);
        I = (f.*T).*w;
        out(N-k+1) = 2*sum(I)/pi;
    end
    out(N) = out(N)/2;
end

if kind == 2 && numel(out) > 1
    out(end) = 2*out(end);
    out = .5*[out(1:2) out(3:end)-out(1:end-2)];
end

