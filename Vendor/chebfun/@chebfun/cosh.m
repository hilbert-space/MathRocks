function Fout = cosh(F)
% COSH   Hyperbolic cosine of a chebfun.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

for k = 1:numel(F)
    if any(get(F(k),'exps')), error('CHEBFUN:cosh:inf',...
        'Chebfun cannot handle exponential blowups'); end
end

Fout = comp(F, @(x) cosh(x));
for k = 1:numel(F)
    Fout(k).jacobian = anon('diag1 = diag(sinh(F)); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F'},{F(k)},1,'cosh');
    Fout(k).ID = newIDnum();
end
