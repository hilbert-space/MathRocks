function Z = zeros(d,m)
% ZEROS  Zero linop or chebfun.
% ZEROS(D) returns a linop representing multiplication by zero for
% chebfuns defined on the domain D.
%
% ZEROS(D,M) returns a chebfun quasimatrix with M column chebfuns that are
% identically zero.
%
% ZEROS(M,D) returns a chebfun quasimatrix with M row chebfuns that are
% identically zero.
%
% See also DOMAIN/ONES, DOMAIN/EYE, CHEBOP.

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.


if nargin==1    % return linop
    if isempty(d)
        Z = linop;
    else
        Z = linop( @(n) makesparse(d,n), @(u) 0*u, d );
        Z.iszero = 1; Z.isdiag = 1;
    end
else            % return chebfun
    if isnumeric(d) % number given first
        z = chebfun(0,m);
        Z = repmat(z.',d,1);
    else
        z = chebfun(0,d);
        Z = repmat(z,1,m);
    end
end
end

function s = makesparse(d,n)
[n map breaks numints] = tidyInputs(n,d,mfilename);
s = sparse(sum(n),sum(n));
end