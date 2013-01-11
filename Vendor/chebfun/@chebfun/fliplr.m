function F = fliplr(F)
% FLIPLR  Flip/reverse a chebfun or quasimatrix.
% 
% G = FLIPLR(F) returns a row chebfun G, if F is a row chebfun, with the
% same domain as F but reversed; that is, G(x)=F(a+b-x), where the domain
% is [a,b]. 
% 
% If F is a row quasimatrix, FLIPLR(F) applies the above operation is to
% each row of F.
%
% If F is a column chebfun, FLIPLR(F) has no effect. If F is a column
% quasimatrix, FLIPLR(F) reverses the order of the columns. 
%
% See also chebfun/flipud.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

F = flipud(F')';