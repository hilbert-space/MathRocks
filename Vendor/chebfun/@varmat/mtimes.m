function C = mtimes(A,B)
% *  Matrix multiplication of varmats, with scalar expansion.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isnumeric(B)
  n = size(B,1);
  C = feval(A,n)*B;
else
  C = op_scalar_expand(@mtimes,A,B);
end

end
  