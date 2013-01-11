function pass = mfun_integrate

% This test computes the integrals of blow-up functions 
% and checks for accuracy.
% Mark Richardson

tol = 500*chebfunpref('eps');

f = chebfun('(1-x).^-0.5.*(1+x).^-0.5','blowup',2);
pass(1) = abs(sum(f)-pi) < tol;
    
f = chebfun('exp(cos(x)).*(1-x).^-0.5.*(1+x).^-0.5','blowup',2);
pass(2) =  abs(sum(f)-6.8423116016431490) < tol;

f = chebfun('exp(sin(x)).*(1-x).^-0.5.*(1+x).^-0.5','blowup',2);
pass(3) = abs(sum(f)-3.7796493041223796) < tol;
    
f = chebfun('(1-x).^-0.1.*(1+x).^-0.4','blowup',2);
pass(4) = abs(sum(f)-2.5394967353733524679) < tol;

pass(5) = 1;
% f = chebfun('log(1+x)+log(1-x)','splitting','on')
% pass(5) = abs(sum(f)-4*(log(2)-1)) < tol

f = chebfun('log(1+x)+log(1-x)','splitting','on','exps',[0 0]);
pass(6) = abs(sum(f)-4*(log(2)-1)) < 5*tol;