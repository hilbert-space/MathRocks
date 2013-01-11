function Fout = erfcx(F)
% ERFCX  Scaled complementary error function of a chebfun.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

Fout = comp(F, @(x) erfcx(x));
for k = 1:numel(F)
  Fout(k).jacobian = anon('diag1 = diag(-2/sqrt(pi) + 2*F.*Fout); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F' 'Fout'},{F(k) Fout(k)},1,'erfcx');
  Fout(k).ID = newIDnum();
end