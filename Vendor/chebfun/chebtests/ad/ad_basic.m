function pass = ad_basic
% Tests basic AD functionality:
%   * arithmetic operators: plus, minus, times, divide, power, sqrt
%   * analytic operations: diff and cumsum
%   * elementary functions: sin, exp, log, cos
%   * systems of equations
% Asgeir

tol = max(10*chebfunpref('eps'),1e-13);

%% Initialize domain, x and the chebfun 1
d = [1,3];
x = chebfun(@(x) x, d);
one = chebfun(1,d);
%% Plus, minus, scalar times, power
u = 2 + 10*x - x.^3;
J = diff(u,x);
pass(1) = norm( diff(u) - J*one ) < tol;

%% Product rule, quotient rule, sqrt
v = 3 + sqrt(x);
w = u.*v + u./v;
J = diff(w,x);
pass(2) = norm( diff(w) - J*one ) < 100*tol;

%% elementary functions
y = sin(exp(x)) + log(2+cos(x));
J = diff(y,x);
pass(3) = norm( diff(y) - J*one ) < 10*tol;

%% diff and cumsum
u = sin(exp(x));
d = domain(d);
D = diff(d);  C = cumsum(d);
z = u.*(D*u) - C*(u.^2);
J = diff(z,u);
JJ = diag(D*u) + diag(u)*D - 2*C*diag(u);
pass(4) = norm( J(20) - JJ(20) ) < tol;

%% system
J = diff( [D*u-v,u+D*v],[u v] );
r = J*[sin(x),cos(x)];
pass(5) = norm(r,'fro') < tol;

