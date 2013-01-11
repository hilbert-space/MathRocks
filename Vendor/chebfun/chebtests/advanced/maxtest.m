function pass = maxtest
% This test checks max when the difference between the functions 
% have multiple roots. It also checks that max can be called 
% with different syntax.

% Rodrigo Platte
% This used to crash because of double roots in sign.m

z = chebfun('x',[-1 1]);
y=max(abs(z),1-z.^2);
v=max(y,1);
tol = 10*chebfunpref('eps');


pass(1) = norm(v-1) < tol;

% Toby Driscoll
% Checking out syntax of various forms of the call.
y = max([z -z 0.5],[],2);
pass(2) = abs(sum(y)-1.25) < 10*tol;

y = max([sin(2*z) cos(z)]);
pass(3) = abs(sum(y)-2) < 10*tol;

y = max(z.');
pass(4) = (y==1);

y = max([z.'; -z.'; 0.5]);
pass(5) = abs(sum(y)-1.25) < 10*tol;

