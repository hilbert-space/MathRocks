function pass = chebpolyvalmtest
% Test CHEBPOLYVALM for two simple examples. 
% Alex Townsend, April 2013. 

tol = 1e2*chebfunpref('eps');
j = 1; 

% 2 by 2 matrix, with quadratic polynomial. 
A = [1 pi;2*pi 1];
c = [exp(1) pi^2 3];
exact = (c(3)*eye(2) + c(2)*A +c(1)*(2*A^2 - eye(2)));
cheb = chebpolyvalm(c,A);
pass(j) = ( norm(exact - cheb) < tol ); j = j + 1; 

%% Clenshaw beats chebfun/expm. 

n=100; 
f = chebfun(@(x) exp(x)); 
Q = qr(toeplitz(1:n)); A = Q\diag(linspace(-.5,.5,n))*Q;
nonnormal = norm(A'*A - A*A'); 

pass(j) = ( norm(chebpolyvalm(chebpoly(f),A) - expm(A)) < nonnormal*tol ); j = j + 1; 
pass(j) = ( norm(chebpolyvalm(f.coeffs,A) - expm(A)) < nonnormal*tol ); j = j + 1; 

end