function C = uminus(A)
% -   Negate oparray.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(A) 
  C = oparray({});
  return
end

fun = @(a) anon('@(u) -feval(a,u)',{'a'},{a},2);
op = cellfun( fun, A.op, 'uniform',false );
C = oparray(op);

end
