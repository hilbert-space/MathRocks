function f = transpose(f)
%.'   Transpose
% F.' is the non-conjugate transpose of F.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% This function is just memory manipulation. 
fun = f.fun2; temp = fun; 
temp.C = (fun.R).'; temp.R = (fun.C).';
fun = temp; f.fun2 = fun; 

end