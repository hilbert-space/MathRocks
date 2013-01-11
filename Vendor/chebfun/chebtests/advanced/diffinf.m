function pass = diffinf
% Tests the computation of derivatives using DIFF when the 
% chebfuns are unbounded by virtue of being defined over 
% infinite domains.

tol = 500*chebfunpref('eps');

x = chebfun('x',[0 inf]);
f = diff(.5*x.^2);
pass(1) = norm(f-x,inf) < tol;
f = diff(x.^3/3);
pass(2) = norm(f-x.^2,inf) < tol;

x = chebfun('x',[-inf 0]);
f = diff(.5*x.^2);
pass(3) = norm(f-x,inf) < tol;
f = diff(x.^3/3);
pass(4) = norm(f-x.^2,inf) < tol;

x = chebfun('x',[-inf inf]);
f = diff(.5*x.^2);
pass(5) = norm(f-x,inf) < tol;
f = diff(x.^3/3);
pass(6) = norm(f-x.^2,inf) < tol;





