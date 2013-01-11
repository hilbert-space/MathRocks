function varargout = find(f)
% FIND  Find locations of nonzeros in a chebfun.
%
% FIND(F) returns a vector of all values at which the chebfun F is nonzero. 
%
% [R,C] = FIND(F) returns two column vectors of the same length such that
% [ F(R(n),C(n)) for all n=1:length(R) ] is the list of all nonzero
% values of the quasimatrix F. One of the outputs holds dependent variable
% values, and the other holds quasimatrix row or column indices. 
%
% If the set of nonzero locations is not finite, an error is thrown.
%
% Example:
%   f = chebfun(@sin,[0 2*pi]);
%   format long, find(f==1/2) / pi
%    
% See also chebfun/roots, chebfun/eq, find.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if numel(f) > 1 && nargout<2
  error('CHEBFUN:find:quasiout','Use two output arguments for quasimatrices.')
end

x = [];  idx = [];
% Keep track of the abscissae and the row/column in which they are found.
for n = 1:numel(f)
  for k = 1:f(n).nfuns
    if any(f(n).funs(k).vals)
      % Continuous part is not identically zero!
      error('CHEBFUN:find:infset','Nonzero locations are not a finite set.')
    end
  end

  xnew = f(n).ends( f(n).imps(1,:)~=0 );  % does all the real work
  x = [ x xnew ];
  idx = [ idx repmat(n,size(xnew)) ];
end

if nargout==1
  % Output has same shape as input. 
  if ~f(1).trans, x=x.'; end
  varargout = {x};
else
  % Output is always column, but order matters.
  if ~f(1).trans
    varargout = {x.',idx.'};
  else
    varargout = {idx.',x.'};
  end
end

end
  