function f = cumsum(f,dim)
%CUMSUM Indefinite integral of a chebfun2.
%
% F = CUMSUM(F) returns the indefinite integral of a chebfun2 with respect
% to one variable and hence, returns a chebfun. The integration is done
% by default in the y-direction.
%
% F = CUMSUM(F,DIM). If DIM = 2 integration is along the x-direction, if
% DIM = 1 integration is along the y-direction.
%
% See also CUMSUM2.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.


mode = chebfun2pref('mode');
rect = f.corners;

if ( nargin == 1 ) % default to integration along the y-direction.
    dim = 1;
end

fun = f.fun2;
if ( isempty(f) ) % check for empty chebfun2.
    f=0;
    return;
end

C = fun.C;
R = fun.R;

if ( mode == 0 )
    C = chebfun(C, rect(3:4));
    R = chebfun(R.', rect(1:2)).';
end

if( dim == 1 )
    % cumsum along the columns.
    C = cumsum(C);
elseif( dim == 2 )
    % cumsum along the rows.
    R = cumsum(R.').';
else
    error('CHEBFUN2:CUMSUM:DIM','Integration direction must be x or y');
end

if ( mode == 0 )
    x = chebpts(length(C), rect(3:4));
    C = C(x,:);
    fun.C = C;
    x = chebpts(length(R), rect(1:2));
    S = R.'; 
    R = S(x,:).';
    fun.R = R;
else
   fun.C = C; 
   fun.R = R; 
end

f.fun2 = fun;

end