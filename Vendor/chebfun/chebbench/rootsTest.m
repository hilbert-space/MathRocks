function rootsTest

f = chebfun(@(x) sin(pi*1000*x),4093);

roots(f);
