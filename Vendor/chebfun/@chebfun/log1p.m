function Fout = log1p(F)
% LOG1P   Accurate logarithm for chebfuns with small values.
%
% LOG1P(Z) computes log(Z+1) accurately in the case where the chebfun Z is
% small on its domain. Complex Z is acceptable.
%
% See also LOG1P, CHEBFUN/EXPM1.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

Fout = F;
for k = 1:numel(F)
    Fout(k) = logcol(F(k));
    Fout(k).jacobian = anon('diag1 = diag(1./(F+1)); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F'},{F(k)},1,'log1p');
    Fout(k).ID = newIDnum();
end

function Fout = logcol(F)

pref = chebfunpref;
% Add breakpoints at roots
if ~isreal(F)
    r = roots(imag(F));
    pref.extrapolate = true;
else
    r = roots(F+1);
end
F = add_breaks_at_roots(F,[],r);

Fout = comp(F, @(x) log1p(x), [], pref);