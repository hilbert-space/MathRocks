function out = legpoly(f)
% LEGPOLY   Legendre polynomial coefficients.
% A = LEGPOLY(F) returns the coefficients such that
% F = a_N P_N(x)+...+a_1 P_1(x)+a_0 P_0(x) where P_N(x) denotes the N-th
% normalized Legendre polynomial.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

ends = f.map.par(1:2);
f.exps = [0 0];

E = chebfun;
% Legendre matrix
for k = 0:f.n-1
    E(:,k+1) = legpoly(k,ends);  
end

% Coefficients are computed using inner products.
norm2 = (ends(2)-ends(1))./(2*(0:f.n-1)+1).'; % 2-norm squared
out = flipud((E'*chebfun(f,ends))./norm2).';
