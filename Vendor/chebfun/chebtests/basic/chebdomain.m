function pass = chebdomain
% Tests the chebfun constructor using the domain class.
% R. Platte 12 Sept 2008

d = domain(0,30);

f1 = chebfun(@(x) exp(-x), d, 10);
f2 = chebfun(@(x) exp(-x), [0 30], 10);

f3 = chebfun(@(x) exp(-x), d);
f4 = chebfun(@(x) exp(-x), [0 30]);

pass(1) = isequal(f1,f2);
pass(2) = isequal(f3,f4);
