function pass = ellipjtest
% Test the accuracy of the Chebfun overload of the 
% Jacobi elliptic functio, ELLIPJ.

pass = test(.005);
pass = [pass test(.995)];


function pass = test(m)
tol = 100*chebfunpref('eps');

K = ellipke(m);
x = chebfun('x',[0,4*K]);
[sn cn dn] = ellipj(x,m);

% test values
pass(1) = abs(sn(K)-1)<tol && abs(cn(K))<tol && abs(dn(K)-sqrt(1-m))<tol;

% test periodicity
pass(2) = abs(sn(0)-sn(4*K))<tol && abs(sn(0)-sn(4*K))<tol && abs(dn(K)-dn(3*K))<tol;

% test relations
% pass(3) = norm(-dn.^2+1-m*sn.^2,inf) < tol;
% pass(4) = norm(sn.^2+cn.^2-1,inf) < tol;
