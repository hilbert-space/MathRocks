function fout = not(F)
% ~   Chebfun logical NOT.
%
%  NOT returns a chebfun which evaluates to zero at all points where f is
%  zero and one otherwise.
%
%  Example:
%       f = ~chebfun(0);
%       g = ~chebfun(@(x) x); g([-1 0 1])
%       
%  See also CHEBFUN/EQ.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

fout = chebfun;
for k = 1:min(size(F)) % Do it for each column of F1.
    fout(k) = notcol(F(k));
end

function fout = notcol(f)
% Not for one single chebfun 

fout = sign(f);

for k = 1:fout.nfuns
    if fout.funs(k).vals(1) == 0
        fout.funs(k).vals = 1;
        fout.funs(k).n = 1;
    else 
        fout.funs(k).vals = 0;
        fout.funs(k).n = 1;
    end
end

tol = max(100*chebfunpref('eps')*f.scl,eps);
fout.imps = abs(feval(f,fout.ends(1,:))) < tol;
