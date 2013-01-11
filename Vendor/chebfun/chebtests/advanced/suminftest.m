% Test a few things involving sum applied to
% functions with infinities.   LNT & NH 4 Dec. 2009.
% (A Level 1 chebtest)

function pass = suminftest

a = 33.4*pi; b = 34.6*pi; c = 33.5*pi; d = 34.5*pi;
f = chebfun('tan(x)',[a c d b],'exps',[0 -1 -1 0]);
pass(1) = isnan(sum(f));

f2 = chebfun('tan(x).^2',[a c d b],'exps',[0 -2 -2 0]);
pass(2) = (sum(f2)==inf);

f3 = chebfun('-tan(x).^4',[a c d b],'exps',[0 -4 -4 0]);
pass(3) = (sum(f3)==-inf);

f4 = chebfun('1+1./x.^2',[1 inf]);
pass(4) = (sum(f4)==inf);

f5 = chebfun('1./x',[1 inf]);
pass(5) = (sum(f5)==inf);

f6 = chebfun('1./x',[-inf -1]);
pass(6) = (sum(f6)==-inf);

f7 = chebfun('1./x.^0.9',[1 inf]);
pass(7) = (sum(f7)==inf);

f8 = chebfun('1./x.^1.1',[1 inf]);
pass(8) = ~isinf(sum(f8));

f9 = chebfun('-1+1./x.^2',[1 inf]);
pass(9) = (sum(f9)==-inf);

f10 = chebfun('x./(1+x.^2)',[-inf inf]);
pass(10) = isnan(sum(f10));
