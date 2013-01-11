function convTest

f = chebfun(@(x) exp(-10*x.^2));
x = chebfun(@(x) x, [-1 0 1]);
g = abs(x);

conv(f,g);