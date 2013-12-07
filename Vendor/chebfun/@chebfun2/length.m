function varargout = length(f)
%LENGTH  The rank of a chebfun2.
%
% K = LENGTH(F) returns the rank of the chebfun2.
%
% [m,n] = LENGTH(F) returns the polynomial degree of the column and row
%        slices.
%
% See also RANK.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

[C D R]=cdr(f);

if ( nargout < 2 )
    len = length(D);
    if ( len == 1 && isinf(abs(D)) ) % check for 0 chebfun2
        len=0;
    end
    varargout = {len};
elseif nargout == 2
    varargout = {length(C), length(R)};
else
    error('CHEBFUN2:length:nargout','Too many output arguments');
end

end