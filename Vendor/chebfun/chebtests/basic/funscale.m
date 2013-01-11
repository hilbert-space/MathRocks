function pass = funscale

% Check that fun scales have been correctly updated after
% applying some operations. 
%
% Rodrigo Platte, July 2009.

f = chebfun({1e-5, 1e-10, 2},[-1 0 1 2]);
x = chebfun('x',f.ends);

pass(1) = f.scl == 2;

pass(2) = true;
g = f.*x;
for k = 1:length(g.ends)-1
    pass(2) = pass(2) && g.funs(k).scl.v == 4;
end

pass(3) = true;
g = f.*chebfun(1,f.ends);
for k = 1:length(g.ends)-1
    pass(3) = pass(3) && g.funs(k).scl.v == 2;
end
