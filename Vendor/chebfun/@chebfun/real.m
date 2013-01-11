function Fout = real(F)
% REAL   Complex real part of a chebfun.
%
% REAL(F) is the real part of F.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

Fout = F;
for k = 1:numel(F)
    Fout(k) = realcol(F(k));
end
% ---------------------------

function fout = realcol(f)

fout = f;
for i = 1:f.nfuns
    fout.funs(i) = real(f.funs(i));
end
fout.imps = real(f.imps);