function Fout = cotd(F)
% COTD   Cotangent of a chebfun in degrees.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

for k = 1:numel(F)
    if any(get(F(k),'exps')<0), error('CHEBFUN:cotd:inf',...
        'COTD is not defined for functions which diverge to infinity'); end
end

Fout = comp(F, @(x) cotd(x));
for k = 1:numel(F)
    Fout(k).jacobian = anon('diag1 = diag(-(pi/180)*cscd(F).^2); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F'},{F(k)},1,'cotd');
    Fout(k).ID = newIDnum();
end