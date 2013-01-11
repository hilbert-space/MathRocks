function C = plus(A,B)
% +  Sum of linops.
% If A and B are linops, A+B returns the linop that represents their
% sum. If one is a scalar, it is interpreted as the scalar times the
% identity operator.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isa(A,'double')
    C=A; A=B; B=C;    % swap to make A a linop
end

% Scalar expansion using identity.
if isnumeric(B)
    if numel(B) == 0  % linop + [] = linop
        C = A;
    elseif numel(B)==1
        if B==0, C=A; return
        elseif diff(A.blocksize)~=0
            error('LINOP:plus:expandsquare',...
                'Scalars can be added only to square linops.')
        end
        m = A.blocksize(1);
        B = B*blockeye(domain(A),m);
        C = A+B;
        C = setbc(C,getbc(A));
    elseif size(B,1) == size(B,2)
        if A.numbc > 0
            A = feval(A,size(B,1),'bc');
        else
            A = feval(A,size(B,1));
        end
        C = A+B;
    end
    return
end

if isa(B,'linop') % linop + linop
    dom = domaincheck(A,B);
    
    % If one linop happens to be the zero linop, we return the other one
    if A.iszero
        C = B;
        return
    elseif B.iszero
        C = A;
        return
    end
    
    if ~all(A.blocksize==B.blocksize)
        error('LINOP:plus:sizes','Chebops must have identical sizes.')
    end
    
    op = A.oparray + B.oparray;
    order = max( A.difforder, B.difforder );
    isz = ~(~A.iszero+~B.iszero);
    isd = A.isdiag & B.isdiag;
    order(isz) = 0;
    C = linop( A.varmat+B.varmat, op, dom, order );
    C.blocksize = A.blocksize;
    C.iszero = isz;
    C.isdiag = isd;
    
else
    error('LINOP:plus:badoperand','Unrecognized operand.')
    
end

end