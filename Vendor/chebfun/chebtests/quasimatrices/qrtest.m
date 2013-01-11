function pass = qrtest

% Tests QR factorization of Chebfun quasimatrices.
% Test 2 confirms that the columns of Q are orthonormal.
% Test 3 confirms that the Q and R factors have the right product.
% (A Level 2 Chebtest)

% Nick Trefethen  24 June 2008
tol = chebfunpref('eps');
x = chebfun('x',[0 1]);
A = [x 1i*x 1 1+1i (2-1i)*x];
pass(1) = (rank(A)==2);
[Q,R] = qr(A);
pass(2) = (abs(cond(Q)-1)<1e-13*(tol/eps));
pass(3) = (norm(A-Q*R)<1e-13*(tol/eps));
