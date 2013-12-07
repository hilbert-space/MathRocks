function f = poly(v,d)
%POLY(V,D), when V is a vector and D is a domain, is a chebfun of 
% degree length(V) and domain D whose roots are the elements of V.
%
% See also CHEBFUN/POLY.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if min(size(v) > 1)
    error('CHEBFUN:domain:poly:vec','domain/poly only supports vector input.');
end

% Remove infs, and return NaN if NaN present.
v = v(~isinf(v));
if any(isnan(v))
    f = chebfun(NaN,d);
    return
end

% Return empty chebfun if v is empty.
N = length(v);
if N == 0
    f = chebfun;
    return
end

% Leja ordering
[ignored j] = max(abs(v));
z = v(j);
v(j) = [];
for k = 1:N-1
    P = zeros(N-k,1);
    for l = 1:(N-k)
        P(l) = prod(z-v(l));
    end
    [ignored j] = max(abs(P));
    z(k+1) = v(j);
    v(j) = [];
end
v = z;

% Evaluate at Chebyshev points
x = chebpts(N+1,d);
p = ones(N+1,1);
for k = 1:N
    p = p.*(x-v(k));
end

% Contruct the chebfun
f = chebfun(p,d);

end
