function C = op_scalar_expand(op,A,B)

% Apply a function of two matrices, expanding one of the arguments if it
% happens to be scalar. Expansion is the usual matlab sense of copying a
% scalar to every position in the array.

% Copyright 2008 by Toby Driscoll.
% See www.comlab.ox.ac.uk/chebfun.

if isnumeric(A) %&& numel(A)==1
  C = varmat( @(n) op(A,feval(B,n)) );
elseif isnumeric(B)% && numel(B)==1
  C = varmat( @(n) op(feval(A,n),B) );
else
  C = varmat( @(n) op(feval(A,n),feval(B,n)) );
end
end
