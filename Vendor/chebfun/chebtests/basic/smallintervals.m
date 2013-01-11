function pass = smallintervals
% Tests of operations on small intervals
% Rodrigo Platte, July 2008.
% (A Level 0 Chebtest)

splitting on

f1 = chebfun(@(x) x,[-1 -1+eps/2 0]);
f2 = chebfun(@(x) x,[-1 -eps/2 0]);
f3 = chebfun(@(x) x.^2, [-1 0]);

pass = norm(f1.*f2 - f3,inf) < 10*chebfunpref('eps');

f2 = chebfun(@(x) x, [-1 -1+eps 0]);
pass(2) = norm(f1.*f2 - f3,inf) < 10*chebfunpref('eps');

% h = chebfun(@(x) 1-abs(x));
% f = conv(h,conv(h,h));
% %pass = pass && all(f.ends==(-3:3)); % This may fail for very loose
% %tolerances
% pass = pass && all(f.ends==round(f.ends));
