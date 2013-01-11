function pass = chebpadetest
% Test the chebpade function against some examples.
%
% Ricardo Pachon 02/09/2009

tol = chebfunpref('eps');

M = 4;
N = 4;
d = [-1, 3];
P = chebfun(chebpolyval([-0.6817    0.0558    2.1122   -1.3813    0.5045]),d);
Q = chebfun(chebpolyval([0.5246   -0.2679   -0.8573    0.1155    1]),d);
R = P./Q;
[p q r] = chebpade(R,M,N,'maehly');
err = norm(chebfun(P.funs(1),d(1:2))-p)+norm(chebfun(Q.funs(1),d(1:2))-q);
pass(1) = err < 100*tol*R.scl;


M = 6;
N = 5;
[p q r] = chebpade( P./Q,M,N,'maehly');
err = norm(chebfun(P.funs(1),d(1:2))-p)+norm(chebfun(Q.funs(1),d(1:2))-q);
pass(2) = err < 100*tol*R.scl;

% an example by Geddes
a0 = 9703/34000;
a1 = 1333/8160;
a2 = 2129/51000;
a3 = 13/3400;
a4 = 512/6375;
a5 = 349/12750;
a6 = -742/6375;
a7 = -464/6375;
b0 = 1;
b1 = -28/85;
b2 = -32/85;
op = @(x) (a0+a1*x+a2*x.^2+a3*x.^3+a4*x.^4+a5*x.^5+a6*x.^6+a7*x.^7)./...
    (b0+b1*x+b2*x.^2);
f = chebfun(op);
[p q r] = chebpade(f,7,2);
err = norm(f-p./q,inf);
pass(3) = err < 2e-15;
cp = chebpoly(p);
pass(4) = cp(end)-17/46 < 1e-13;


