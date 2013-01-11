function Fout = cos(F)
% COS   Cosine of a chebfun.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

for k = 1:numel(F)
    if any(get(F(k),'exps')<0), error('CHEBFUN:cos:inf',...
        'COS is not defined for functions which diverge to infinity'); end
end

Fout = comp(F, @(x) cos(x));
for k = 1:numel(F)
    Fout(k).jacobian = anon('diag1 = diag(-sin(F)); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F'},{F(k)},1,'cos');
    Fout(k).ID = newIDnum();
end
