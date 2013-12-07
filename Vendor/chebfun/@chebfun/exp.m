function Fout = exp(F)
% EXP Exponential of a chebfun.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

for k = 1:numel(F)
    if any(F(k).imps(1,:) == inf), error('CHEBFUN:exp:inf',...
        'Chebfun cannot handle exponential blowups.'); end
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
     error('CHEBFUN:exp:inf',...
        'Chebfun cannot handle exponential blowups.'); 
end

Fout = comp(F, @(x) exp(x));
for k = 1:numel(F)
    Fout(k).jacobian = anon('diag1 = diag(exp(F)); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F'},{F(k)},1,'exp');
    Fout(k).ID = newIDnum();
end
