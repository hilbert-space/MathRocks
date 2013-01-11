function pass = pole_construct
% Test to check if Chebfun operations on the basic chebfun 'x'
% involving poles produces an identical result to direct 
% construction. 

% Nick Hale, December 2009

tol = 1e2*chebfunpref('eps');

x = chebfun('x');
f = 1./x;
g = chebfun('1./x',[-1:1],'exps',[0 -1 -1 0]);
pass(1) = ~norm(f-g,inf); % check for exactness

f = 1./x.^2;
g = chebfun('1./x.^2',[-1:1],'exps',[0 -2 -2 0]);
pass(2) = ~norm(f-g,inf); % check for exactness

f = 1./sin(pi*x);
xx = [-.9 -.4 .3 .8];
err = norm(f(xx)-1./sin(pi*xx),inf);
pass(3) = err < tol;

gam = chebfun(@gamma,[-4:4],'blowup',1);
gami = 1./gam;
I = gami.*gam;
err = norm(abs(I-1),inf);
pass(4) = err < 10*tol;
