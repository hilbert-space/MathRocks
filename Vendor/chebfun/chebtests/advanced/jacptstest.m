function pass = jacptstest
% This test computes Legrendre points with Gauss quadrature weights. It
% checks the accuracy by comparing quadrature results.  It also checks that
% sum on a function which blows-up. 

tol = chebfunpref('eps');

a = 1; 
b = 5; 
alpha = .3; 
beta = -.4;

f = @(x)sin(x);
F = @(x)(x-a).^beta.*(b-x).^alpha.*f(x);

warnstate = warning; warning off
if verLessThan('matlab','7.5')    
    % There's no quadgk before 7.5
    vquadgk = quadl(F,a,b,1e-10);
else
    vquadgk = quadgk(F,a,b,'abstol',1e-10,'reltol',1e-10);
end

warning(warnstate);

njac=20; c1=(b+a)/2; c2=(b-a)/2;

[s,w] = jacpts(njac,alpha,beta);
v1jac = c2^(alpha+beta+1)*w*f(c1+c2*s);

[S,W] = jacpts(njac,alpha,beta,[a,b]);
v2jac = W*f(S);

% Check the scaling of the points
pass(1) = norm(v1jac-v2jac,inf) < 100*tol;

% Check the accuracy of the quadrature against quadgk
pass(2) = abs(vquadgk-v2jac) < max(10*tol,1e-8);

% Check accuracy of sum
pass(3) = abs( sum(chebfun(F,[a b],'exps',[beta alpha])) - v2jac) < 100*tol;
