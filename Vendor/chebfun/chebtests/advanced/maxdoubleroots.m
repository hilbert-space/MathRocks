function pass = maxdoubleroots

% Tests max(f,g) when f-g has double roots.

f = chebfun(@(x) sin(100*x));
g = chebfun(1);

pass = min(max(f,g)) == 1;