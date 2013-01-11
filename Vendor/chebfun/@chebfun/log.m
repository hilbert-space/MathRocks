function Fout = log(F)
% LOG   Natural logarithm of a chebfun.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

Fout = F;
for k = 1:numel(F)
    Fout(k) = logcol(F(k));
    Fout(k).jacobian = anon('diag1 = diag(1./F); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F'},{F(k)},1,'log');
    Fout(k).ID = newIDnum();
end

function Fout = logcol(F)

pref = chebfunpref;
% Add breakpoints at roots
if ~isreal(F)
    r = roots(imag(F));
    pref.extrapolate = true;
else
    r = roots(F);
end
F = add_breaks_at_roots(F,[],r);

Fout = comp(F, @(x) log(x), [], pref);