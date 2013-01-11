function Fout = asecd(F)
% ASECD   Inverse secant of a chebfun, result in degrees.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

Fout = comp(F, @(x) asecd(x));
for k = 1:numel(F)
    Fout(k).jacobian = anon('diag1 = diag((180/pi)./(abs(F).*sqrt(F.^2-1))); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F'},{F(k)},1,'asecd');
    Fout(k).ID = newIDnum();  
end
