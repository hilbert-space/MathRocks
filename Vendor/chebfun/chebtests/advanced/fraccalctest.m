function pass = fraccalctest
% Perform some tests for fractional derivatives
% Nick Hale, Feb 2010

tol = 100*chebfunpref('eps');

% polynomials
x = chebfun('x',[0 1]);
q = sqrt(2)/2;
k = 0;
for n = [1 4]
    k = k+1;
    xn = x.^n;
    xnpq = diff(xn,q);
    tru = gamma(n+1)./gamma(n+1-q)*chebfun(@(x) x.^(n-q),[0 1],'exps',[n-q 0]); 
    pass(k) = norm(tru-xnpq,inf) < tol;
end

% exponential
u = chebfun('exp(x)',[0 1]);
trueRL = chebfun('erf(sqrt(x)).*exp(x) + 1./sqrt(pi*x)',[0 1],'exps',[-.5 0]);
trueC = chebfun('erf(sqrt(x)).*exp(x)',[0 1],'exps',[.5 0]);

%RL
up05 = diff(u,.5,[],'RL');
uint05 = cumsum(u,.5);
pass(3) = norm(get(trueRL-up05,'vals'),inf) < 50*tol;
pass(4) = norm(trueC-uint05,inf) < tol; % Answer for int is actually same as C.

%Caputo
up05 = diff(u,.5,[],'Caputo');
trueC = chebfun('erf(sqrt(x)).*exp(x)',[0 1],'exps',[.5 0]);
pass(5) = norm(trueC-up05,inf) < tol;

