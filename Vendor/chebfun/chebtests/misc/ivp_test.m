function pass = ivp_test
% This test solves the Van der Pol ODEs in Chebfun with ode113. It checks
% the solution against Matlab's inbuilt ode113 solver.


% Rodrigo Platte Jan 2009

% Test ode113 Using default tolerances (RelTol = 1e-3)
y = ode113(@vdp1,domain(0,20),[2;0]); % chebfun solution
[tm,ym] = ode113(@vdp1,[0,20],[2;0]); % Matlab's solution

pass(1) = max(max(abs(ym - feval(y,tm)))) < 2e-2;

return
% Skip the rest to save time

% Test ode45 Using default tolerances (RelTol = 1e-3)
y = ode45(@vdp1,domain(0,20),[2;0]); % chebfun solution
[tm,ym] = ode45(@vdp1,[0,20],[2;0]); % Matlab's solution
pass(2) = max(max(abs(ym - feval(y,tm)))) < 1e-2;
%Note: ode45 is still tested in ivp_ty_test.m

% Test with different tolerance
opts = odeset('RelTol', 1e-6);

% Test ode113
y = ode113(@vdp1,domain(0,20),[2;0],opts); % chebfun solution
[tm,ym] = ode113(@vdp1,[0,20],[2;0],opts); % Matlab's solution

pass(3) = max(max(abs(ym - feval(y,tm)))) < 1e-5;

% Test ode45 
y = ode45(@vdp1,domain(0,20),[2;0],opts); % chebfun solution
[tm,ym] = ode45(@vdp1,[0,20],[2;0],opts); % Matlab's solution
pass(4) = max(max(abs(ym - feval(y,tm)))) < 1e-5;


% Test ode45 
y = ode15s(@vdp1,domain(0,20),[2;0],opts); % chebfun solution
[tm,ym] = ode15s(@vdp1,[0,20],[2;0],opts); % Matlab's solution
pass(5) = max(max(abs(ym - feval(y,tm)))) < 1e-5;




