function Fout = erfc(F)
% ERFC   Complementary error function of a chebfun.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

Fout = comp(F, @(x) erfc(x));
for k = 1:numel(F)
  Fout(k).jacobian = anon('diag1 = diag(-2*exp(-F.^2)/sqrt(pi)); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F'},{F(k)},1,'erfc');
  Fout(k).ID = newIDnum();
end