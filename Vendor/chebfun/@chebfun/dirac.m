function d = dirac(f)
% DIRAC delta function
%
% D = DIRAC(F) returns a chebfun D which is zero on the domain of the
% chebfun F except at the roots of F, where it is infinite.
%  
% See also chebfun/heaviside

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

tol = chebfunpref('eps');

[a b] = domain(f);

r = roots(f);
ends = union(r,[a,b]);

if abs(ends(1)-ends(2)) < 10*tol*f.scl, ends(2) = []; end
if abs(ends(end)-ends(end-1)) < 10*tol*f.scl, ends(end-1) = []; end

df = diff(f);
dfends = feval(df,ends(2:end-1));

% if any(dfends(:)==0)
%     error('CHEBFUN:dirac', 'Function has multiple roots');
% end

d = chebfun(0,ends);
d.imps(2,2:end-1) = 1./abs(dfends);

if abs( feval(f,a) ) < 100*tol*f.scl
    d.imps(2,1) = 1;
end
if abs( feval(f,b) ) < 100*tol*f.scl
    d.imps(2,end) = 1;
end




