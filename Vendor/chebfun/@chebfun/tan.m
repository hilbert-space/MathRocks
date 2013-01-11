function Fout = tan(F)
% TAN   Tangent of a chebfun.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

for k = 1:numel(F)
    if any(get(F(:,k),'exps')<0), error('CHEBFUN:tan:inf',...
        'TAN is not defined for functions which diverge to infinity'); end
end

for k = 1:numel(F)
    Fout(k) = coltan(F(k));
    Fout(k).jacobian = anon('diag1 = diag(sec(F).^2); der2 = diff(F,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F'},{F(k)},1);
    Fout(k).ID = newIDnum;
end

function Fout = coltan(F)

% Get default preferences
pref = chebfunpref;
tol = 100*pref.eps;

% Find if F passes through (k+.5)*pi
G = mod(real(F)+pi/2,pi);
lvals = feval(F,G.ends,'left');
rvals = feval(F,G.ends,'right');
lmask = abs(mymod(real(lvals)+pi/2,pi) + 1i*imag(lvals)) < tol;
rmask = abs(mymod(real(rvals)+pi/2,pi) + 1i*imag(rvals)) < tol;
mask = lmask | rmask;
if any(mask)
    % Turn on blowup
    pref.blowup = max(1,pref.blowup);
    if any(any(get(F,'exps'))), pref.blowup = 2; end
    pref.extrapolate = 1;
    pref.skipfunconstruct = 1;
    % Introduce breaks
    newends = setdiff(G.ends(mask),F.ends); 
    if ~isempty(newends)
        F = define(F,newends,feval(F,newends));       
    end
end
 
% Call compose function
Fout = comp(F, @(x) tan(x), pref);

function m = mymod(f,g)
m = min([abs(mod(f,g)) ; abs(mod(f,-g)) ; abs(mod(-f,g)) ; abs(mod(-f,-g))]);