function pass = chebop_delta
% Checks if a linear differential equation with 
% delta functions on the RHS is being solved correctly.

%% First order
x = chebfun('x');
L = chebop(@(u) diff(u));
L.lbc = 0;
f = dirac(x);
pass(1) = norm(L\f - heaviside(x)) < 100*chebfunpref('eps');

%% Second order
L = chebop(@(u) diff(u,2));
L.lbc = 0; L.rbc = 0;
f = 2*(dirac(x+.5)-2*dirac(x)+dirac(x-.5));
pass(2) = norm(L\f-max(1-2*abs(x),0)) < 100*chebfunpref('eps');