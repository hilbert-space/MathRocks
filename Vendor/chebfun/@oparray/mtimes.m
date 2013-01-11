function C = mtimes(A,B)
% *   Compose oparrays or scalar multiply.
% c*A or A*c multiplies the oparray A by scalar c.
% A*B is the oparray that represents the composition of A and B.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(A) || isempty(B)
  C = oparray({});
  return
end

if isnumeric(A)
  C = A; A = B; B = C;
end

if isnumeric(B)   % scalar multiply
%  op = cellfun( @(op) @(u) B*op(u), A.op, 'uniform',false );
  fun = @(op) anon('@(u) B*feval(op,u)',{'B','op'},{B,op},2);
  op = cellfun( fun, A.op, 'uniform',false );
  C = oparray(op);

else              % compose
  if size(A.op,2)~=size(B.op,1)
    error('OPARRAY:mtimes:size','Inner dimensions do not agree.')
  end

  % Emulate matrix * matrix.
  m = size(A.op,1);  n = size(B.op,2);  q = size(A.op,2);
  op = cell(m,n);
  for i = 1:m
    for j = 1:n
      % Tricky: For nested function, must lock in values of i,j.
      op{i,j} = anon('@(u) innersum(u,i,j)',{'innersum','i','j'},{@innersum,i,j},2);
    end
  end
  C = oparray(op);
end

  function v = innersum(u,i,j)
    v = 0;
    for k = 1:q
      v = v + feval(A.op{i,k}, feval(B.op{k,j},u));
    end
  end

end