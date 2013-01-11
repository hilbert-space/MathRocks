function pass = max_min

% Tests max and min of functions.
% Rodrigo Platte, May 2009

tol = chebfunpref('eps');

f = chebfun(@(x) cos(2*pi*(x-pi)).*exp(-x), [0,inf]);
f2 = chebfun(@(x) cos(2*pi*(x-pi)).*exp(-x), [0,1]);

[y1,x1] = max(f);
[y2,x2] = max(f2);

pass(1) = abs(x1-x2)+abs(y1-y2) < tol*100;

[y1,x1] = min(f);
[y2,x2] = min(f2);

pass(2) = abs(x1-x2)+abs(y1-y2) < tol*100;