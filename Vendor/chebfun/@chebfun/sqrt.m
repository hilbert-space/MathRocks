function Fout = sqrt(F)
% SQRT   Square root.
% SQRT(F) returns the square root chebfun of a positive or negative chebfun F.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

Fout = F;
for k = 1:numel(F)
    Fout(k) = sqrtcol(F(k));
    Fout(k).jacobian = anon('diag1 = (1/2)*diag(1./Fout); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'Fout','F'},{Fout(k) F(k)},1,'sqrt');
    Fout(k).ID = newIDnum;
end

end


function Fout = sqrtcol(F)

pref = chebfunpref;
% Add breakpoints at roots
if ~isreal(F)
    r = roots(imag(F));
    pref.extrapolate = true;
else
    r = roots(F);
end
F = add_breaks_at_roots(F,[],r);
Fout = F;

% Loop through funs
for k = 1:F.nfuns
    f = extract_roots(F.funs(k));
    exps = f.exps;
    f.exps = [0 0];
    fout = compfun(f, @sqrt,[],pref);
    fout.exps = exps/2;
    fout = replace_roots(fout);
    Fout.funs(k) = fout;
end

Fout.imps = sqrt(Fout.imps);

end
