function C = hypot(A,B)
% HYPOT  Robust computation of the square root of the sum of squares.
%
% C = HYPOT(A,B) returns SQRT(ABS(A).^2+ABS(B).^2) for two A and B
% chebfuns (or a chebfun and a double) carefully computed to avoid
% underflow and overflow. 
%
% Example:
%        x = chebfun('x',[-1 1]);   
%        a = 3*[1e300*x 1e-300*x];
%        b = 4*[1e300*x 1e-300*x];
%        % c1 = sqrt(a.^2 + b.^2) % This will fail because of overflow
%        c2 = hypot(a,b)

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Insert breaks at roots.
if isa(A,'chebfun')
    for k = 1:numel(A)
        A(k) = define(A(k),roots(A(k)),0);
    end
end
if isa(B,'chebfun')
    for k = 1:numel(B)
        B(k) = define(B(k),roots(B(k)),0);
    end
end

% Call comp
C = comp(A,@hypot,B);

for k = 1:numel(C)                      
    C(k).jacobian = anon(['diag1 = diag(A./C); der1 = diff(A,u,''linop''); ',...
                          'diag2 = diag(B./C); der2 = diff(B,u,''linop''); ',...
                          'der = diag1*der1 + diag2*der2; ',...
                          'nonConst = (~der1.iszero | ~der2.iszero);'],...
                           {'A','B','C'},{A(k),B(k),C(k)},1,'hypot');
    C(k).ID = newIDnum();
end

end 