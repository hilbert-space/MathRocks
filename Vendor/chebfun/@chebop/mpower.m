function C = mpower(A,m)
%^   Repeated composition of a chebop.
% For chebop A and nonnegative integer M, A^M returns the linop
% representing M-fold application of A.

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ~( (numel(m)==1) && (m==round(m)) && (m>=0) )
    error('CHEBOP:mpower:argument',...
        'Exponent must be a nonnegative integer.')
end

if (m > 0)
    C = newIDnum(A);
    for k = 1:m-1
        C = A*C;
    end
else
    C = eye(A.domain);
end

end

