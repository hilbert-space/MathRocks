function Fout = erfcinv(F)
% ERFINV   Inverse of the complementary error function for a chebfun.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

Fout = comp(F, @(x) erfcinv(x));
for k = 1:numel(F)
  Fout(k).jacobian = anon('diag1 = -diag(exp(Fout.^2)*sqrt(pi)/2); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F' 'Fout'},{F(k) Fout(k)},1,'erfcinv');
  Fout(k).ID = newIDnum();
end

