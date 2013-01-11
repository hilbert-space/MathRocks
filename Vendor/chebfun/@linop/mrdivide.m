function C = mrdivide(A,B)
% /  Divide linop by scalar.
% A/M for linop A and scalar M returns (1/M)*A. No other syntax is
% supported.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ~isnumeric(B)
  error('LINOP:mrdivide:noright','Right inverses not implemented.')
elseif numel(B)~=1
  error('LINOP:mrdivide:scalaronly','May divide by scalars only.')
end

C = mtimes(1/B,A);

end