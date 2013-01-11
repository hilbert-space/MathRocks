function pass = ratinterptest

% Check a few basics with ratinterp
% A Level 1 Chebtest.

d = [1,3];
x = chebfun(@(x) x, d);
f = abs(exp(x)-5);
[p,q,r] = ratinterp(f,2,3,[],chebpts(6,[1,3],2));
pass(1) = ( (length(p)==3) & (length(q)==4) );
pass(2) = norm(f-p./q,inf)<0.6;
xx = linspace(1,3,300);
pass(3) = max(abs((f(xx)-r(xx))))<0.6;
[p,q,r] = ratinterp(f,2,3,[],'type2');
pass(4) = norm(f-p./q,inf)<0.6;
pass(5) = max(abs((f(xx)-r(xx))))<0.6;
