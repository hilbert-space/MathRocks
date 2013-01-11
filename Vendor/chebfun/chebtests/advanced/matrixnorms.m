function pass = matrixnorms
% This test constructs a matrix with chebfuns as columns and computes
% norms. It checks the computed matrix norms are correct.
% Nick Trefethen  31 May 2008

tol = 10*eps;
x = chebfun(1,[0 1]);
A = [0*x 0*x 0*x x 0*x];
norms = zeros(4,1);
norms(1) = norm(A,1);
norms(2) = norm(A,2);
norms(3) = norm(A,inf);
norms(4) = norm(A,'fro');
pass = abs(norms-ones(4,1)) < tol;
