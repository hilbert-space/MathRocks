function Fout = expm1(F)
% EXPM1(Z) computes exp(Z)-1 accurately in the case where the chebfun Z is
% small on its domain. Complex Z is acceptable.
%
% See also EXPM1, CHEBFUN/LOG1P.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

for k = 1:numel(F)
    if any(F(:,k).imps(1,:) == inf), error('CHEBFUN:expm1:inf',...
        'Chebfun cannot handle exponential blowups'); end
end

% Check for blowups (+inf)
pos_blowup = false;
for k = 1:numel(F)
    for j = 1:F(k).nfuns
        if get(F(k).funs(j),'lval') == inf || get(F(k).funs(j),'rval') == inf
            pos_blowup = true;
            break
        end
    end
end
if pos_blowup
     error('CHEBFUN:expm1:inf',...
        'Chebfun cannot handle exponential blowups'); 
end

Fout = comp(F, @(x) expm1(x));
for k = 1:numel(F)
    Fout(k).jacobian = anon('diag1 = diag(exp(F)); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = (~diag1.iszero) & ~der2.iszero;',{'F'},{F(k)},1,'expm1');
    Fout(k).ID = newIDnum();
end