function f = cumsum2(f)
%CUMSUM2 Double indefinite integral of a chebfun2.
%
% F = CUMSUM2(F) returns the double indefinite integral of a chebfun2. That
% is,
%                  y  x
%                 /  /
%  CUMSUM2(F) =  |  |   f(x,y) dx dy   for  (x,y) in [a,b]x[c,d],
%                /  /
%               c  a
%
%  where [a,b]x[c,d] is the domain of f. 
% 
% Also see CUMSUM, SUM, SUM2.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.


mode = chebfun2pref('mode'); 
fun = f.fun2;
rect = f.corners; 

if ( isempty(f) ) % check for empty chebfun2.
    f = 0;
    return;
end

if ( mode == 0 )
    C = chebfun(fun.C, rect(3:4));
    R = chebfun(fun.R.', rect(1:2)).';
else
   C = fun.C; 
   R = fun.R;
end

% cumsum along the columns.
C = cumsum(C);
% cumsum along the rows.
R = cumsum(R.').';

if ( mode == 0 )
    x = chebpts(length(C), rect(3:4));
    C = C(x, :);
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