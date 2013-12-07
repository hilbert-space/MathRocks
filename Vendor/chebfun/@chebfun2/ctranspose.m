function f = ctranspose(f)
%'	  Complex conjugate transpose of a chebfun2.
% 
% F' is the complex conjugate transpose of F.
%
% G = CTRANSPOSE(F) is called for the syntax F'.  

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

%% 
% This operations requires no arithmetic operations just some memory
% manipulation. 

fun = f.fun2; % get fun2. 
temp = fun; 
temp.C = (fun.R)';
temp.U = (fun.U)'; % have to do this to on diagonal to complex conj. 
temp.R = (fun.C)';
fun = temp; 
f.fun2 = fun; 

end