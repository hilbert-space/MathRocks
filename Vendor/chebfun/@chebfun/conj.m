function F = conj(F)
% CONJ	 Complex conjugate.
% 
% CONJ(F) is the complex conjugate of F.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

for k = 1:numel(F)
    funs = F(k).funs;
    for j = 1:numel(funs)
        funj = funs(j);
        vals = funj.vals;
        vals = conj(vals);
        funj.vals = vals;
        funj.coeffs = conj(funj.coeffs);
        funs(j) = funj;
    end
    F(k).funs = funs;
    F(k).imps = conj(F(k).imps);
end
