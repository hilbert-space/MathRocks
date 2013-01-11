function varargout = size(A,dim)
% SIZE   Return the block size of a linop.
% The usual syntax of SIZE applies.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

bs = A.blocksize;
if nargin > 1
  bs = bs(dim);
end
if nargout>1
  varargout = num2cell(bs);
else
  varargout = { bs };
end

end
