function Fout = secd(F)
% SECD   Secant of a chebfun in degrees.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

for k = 1:numel(F)
    if any(get(F(k),'exps')<0), error('CHEBFUN:secd:inf',...
        'SECD is not defined for functions which diverge to infinity'); end
end

Fout = comp(F, @(x) secd(x));
for k = 1:numel(F)
    Fout(k).jacobian = anon('diag1 = diag(pi/180*tand(F).*secd(F)); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F'},{F(k)},1,'secd');
    Fout(k).ID = newIDnum;
end