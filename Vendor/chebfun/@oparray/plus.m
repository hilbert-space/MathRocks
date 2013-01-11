function C = plus(A,B)
% +   Sum of oparrays.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(A) || isempty(B)
  C = oparray({});
else
  op = cellfun( @(a,b) anon('@(u) feval(a,u)+feval(b,u)',{'a','b'},{a,b},2), A.op,B.op,...
    'uniform',false );
%  op = cellfun( @(a,b) @(u) a(u)+b(u), A.op,B.op,'uniform',false );

  C = oparray(op);
end

end
