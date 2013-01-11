function fout = diag(L)
%DIAG The diagonal of linear chebop 
% F = DIAG(L) returns the chebfun that lies on the diagonal line of the
% linear operator L. Note that this is not defined if L is nonlinear, and
% not well-defined if it linear but not a diagonal operator. An error and a
% warning are returned respectively in these cases.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

L = linop(L);
fout = diag(L);
