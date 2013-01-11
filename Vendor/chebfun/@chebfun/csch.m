function Fout = csch(F)
% CSCH   Hyperbolic cosecant of a chebfun.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

Fout = comp(F, @(x) csch(x));
for k = 1:numel(F)
    Fout(k).jacobian = anon('diag1 = diag(-coth(F).*csch(F)); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F'},{F(k)},1,'csch');
    Fout(k).ID = newIDnum();
end
