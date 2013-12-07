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
tol = 100*pref.eps;
% Add breakpoints at roots
if ~isreal(F)
    % Compelx Chebfun, separate real and imaginary functions
    U = real(F); 
    V = imag(F);
    % pick the smaller function for root extraction
    if( length(U) < length(V) )
        r = roots(U);
        % make sure it is a root of V as well
        r = r(abs(feval(V,r)) < tol);
    else
        r = roots(V);
        % make sure it is a root of V as well
        r = r(abs(feval(U,r)) < tol);
    end
else
    r = roots(F);
end

if( ~isempty(r) )
    pref.extrapolate = true;
    F = add_breaks_at_roots(F,tol,r);
end

Fout = comp(F, @(x) log(x), [], pref);