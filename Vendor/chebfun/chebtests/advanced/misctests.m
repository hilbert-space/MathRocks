function pass = misclnttests1
% This tests the chebfun constructor with different syntax, sum and norm.
% LNT 24 May 2008

pass(1) = (sum(chebfun(1,2,3,4,5,0:5))==15);
pass(2) = (sum(chebfun(1,1,2i,-2,-1i,-1i,0:6))==0);
x = chebfun('t',[1 2]);
n1 = norm(sin(x).^2+cos(x).^2-1);
pass(3) = (n1<10*chebfunpref('eps'));
n2 = norm(sin(1i*x).^2+cos(1i*x).^2-1);
pass(4) = (n2<100*chebfunpref('eps'));

