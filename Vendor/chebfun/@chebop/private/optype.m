function type = optype(A)
% OPTYPE   Operator type of a chebop
%  OPTYPE(A) returns:
%       0 if A.op isempty
%       1 if A.op is a function_handle
%       2 if A.op is a linop

if isempty(A.op)
    type = 0;
elseif isa(A.op,'function_handle')
    type = 1;
else
    type = 2;
end