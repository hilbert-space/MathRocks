function C = mtimes(A,B)
%* Chebop composition, multiplication, or application.
% If A and B are chebops, then C = A*B is a chebop where the operator of C
% is the composition of the operators of A and B. No boundary conditions
% are applied to C.
%
% If either A or B are scalar, then C = A*B is a chebop representing scalar
% multiplication of the original operator. In this case, boundary
% conditions are copied into the new operator.
%
% If N is a chebop and U a chebfun, then N*U applies N to U. 
%
% See also CHEBOP/MLDIVIDE, CHEBOP/FEVAL

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isa(A,'chebfun')
    error('CHEBOP:mtimes:invalid','Operation is undefined.');
elseif isa(B,'chebfun')
    % Evaluate the chebfun differently depending on whether it's operator
    % is a linop or an anonymous function
    if isa(A.op,'linop')
        C = feval(A.op,B);
    else
        C = feval(A,B);
    end
elseif isnumeric(A) || isnumeric(B)
    % Switch argument to make sure A is numeric
    if isnumeric(B)
        temp = A; A = B; B = temp;
    end
    
    C = B;  % change this if ID's are put in chebops!
    if isa(C.op,'linop')
        C.op = A*C.op;
    else
        funString = func2str(C.op);
        firstRightParLoc = min(strfind(funString,')'));
        funArgs = funString(2:firstRightParLoc);
        C.op = eval(['@',funArgs,'A*C.op',funArgs]);
    end
    C.opshow = cellfun(@(s) [num2str(A),' * (',s,')'],B.opshow,'uniform',false);
elseif isa(A,'chebop') && isa(B,'chebop')
    if ~all(A.domain.ends == B.domain.ends)
        error('CHEBOP:mtimes:domain','Domains of operators do not match');
    end
    
    % When L*u is allowed, these checks will not be necessary anymore
    if optype(A) == 1
        if optype(B) == 1
            C = chebop(A.domain, @(u) A.op(B.op(u)));
        else
            C = chebop(A.domain, @(u) A.op(B.op*u));
        end
    else
        if optype(B) == 1
            C = chebop(A.domain, @(u) A.op*(B.op(u)));
        else
            C = chebop(A.domain, A.op*B.op);
        end        
    end
    
    C.opshow = cellfun(@(s,t) [s, ' composed with ',t],A.opshow,B.opshow,...
      'uniform',false);
else
    
end