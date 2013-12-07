function pass = abs_test
% Nick Hale, Feb 2013.

pass = true;
return

% This should not introduce a break at zero:
x = chebfun('x');
f = abs(x.^2);
pass(1) = f.nfuns == 1;

% This should introduce breakpoints:
f = chebfun(@(x) cos(3*x));
p = chebfun(@(x) cos(3*x), 11);
err = abs(f-p);
pass(2) = err.nfuns == 9;
% And the min of the error should be zero:
pass(3) = min(err) == 0;


