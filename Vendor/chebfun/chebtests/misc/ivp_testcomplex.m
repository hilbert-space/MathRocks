function pass = ivp_testcomplex

% Nick Trefethen March 2009
% This routine tests ode45, ode113, ode15s on a complex ode to
% make sure we get the signs right

f = @(x,u) 1i*u;
d = domain(0,1);

y = ode113(f,d,1);
pass(1) = abs(y(1)-exp(1i)) < 2e-2;

y = ode45(f,d,1);
pass(2) = abs(y(1)-exp(1i)) < 2e-2;

y = ode15s(f,d,1);
pass(3) = abs(y(1)-exp(1i)) < 2e-2;
