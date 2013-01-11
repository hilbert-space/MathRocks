function f = chebpoly(n,d,kind)
%CHEBPOLY   Chebyshev polynomial of degree n.
% F = CHEBPOLY(N) returns the chebfun corresponding to the Chebyshev
% polynomials T_N(x) on [-1,1], where N may be a vector of positive
% integers.
%
% F = CHEBPOLY(N,D), where D is an interval or a domain, gives the same 
% result scaled accordingly.
%
% F = CHEBPOLY(N,KIND) or F = CHEBPOLY(N,D,KIND) switches between Chebyshev
% polynomials of the 1st kind, T_N(x)), when KIND = 1, and Chebyshev
% polynomials of the 2nd kind, U_N(x)), when KIND = 2. (Note, similarly to
% CHEBPTS, CHEBPOLY will always return 1st kind polynomials, regardless of
% chebfunpref('chebkind').)
%
% See also chebfun/chebpoly, legpoly, and chebpts.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

% Defaults
defkind = 1;

% Parse input
if nargin == 1
    d = chebfunpref('domain');
    kind = defkind;
elseif nargin == 2
    kind = defkind;
    if numel(d) == 1 && ~isa(d,'domain')
        kind = d;
        d = chebfunpref('domain');
    end
end    

if any(isinf(d))
    error('CHEBFUN:chebpoly:infdomain', ...
    'Chebyshev polynomials are not defined over an unbounded domain.');
end

% Loop over n
f = chebfun;
for k = 1:length(n)
    % Values at 2nd kind points.
    vk = ones(1,n(k)+1); 
    vk(end-1:-2:1) = -1;
    
    % Modify for polynomials of the 2nd kind.
    if kind == 2, vk(1) = (n(k)+1)*vk(1); vk(end) = n(k)+1; end
    f(:,k) = chebfun(vk,d);
end

if size(n,1) > 1, f = f.'; end

