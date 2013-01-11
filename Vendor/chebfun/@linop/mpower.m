function C = mpower(A,m)
% ^   Repeated application of a linop.
% For linop A and nonnegative integer M, A^M returns the linop
% representing M-fold application of A.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ~((numel(m)==1)&&(m==round(m))&&(m>=0))
  error('LINOP:mpower:argument','Exponent must be a nonnegative integer.')
end

s = A.blocksize;
if s(1)~=s(2) 
  error('LINOP:mpower:square','Oparray must be square')
end

if (m > 0) 
  C = linop(A.varmat^m, A.oparray^m, A.domain );
  
  % Find the zeros
  isz = ~double(~A.iszero)^m;
  
  % Find the diagonals
  isd = zeros(size(A));
  for i1 = 1:size(A,1)
      for i2 = 1:size(A,2)
          isd(i1,i2) = double(logical(A.isdiag(i1,:)+A.iszero(:,i2)'))*double(logical(A.iszero(i1,:)'+A.isdiag(:,i2)));
      end
  end
  isd = isd == size(A,2);
  
  % Get the difforder
  difforder = A.difforder;
  for j = 2:m
      [jj kk] = meshgrid(1:s(1),1:s(2));
      order = zeros(numel(jj),s(2));
      zr = zeros(numel(jj),s(2));
      tmp = double(~A.iszero)^(j-1);
      for l = 1:size(A,2)
          order(:,l) = difforder(jj,l)+A.difforder(l,kk)';
          zr(:,l) = ~(tmp(jj,l).*~A.iszero(l,kk)');
      end
      order(logical(zr)) = 0;
      order = max(order,[],2);
      difforder = reshape(order,s(1),s(2))';
  end
  difforder(isz) = 0;
 
  C.difforder = difforder;
  C.blocksize = s;
  C.iszero = isz;
  C.isdiag = isd;
  
      if ~all(size(C)==size(C.difforder))
        error
      end
    
else
  C = blockeye(A.domain,s(1));
end

end

