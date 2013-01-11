function pass = exps_diff
% Tests diff with exponents
% Nick Hale, Nov 2009

tol = chebfunpref('eps');

f = chebfun(@(x) sin(x)./sqrt(1-x.^2),'exps',[-.5 -.5]);
g = chebfun(@(x) (x.*sin(x)+cos(x).*(1-x.^2))./(1-x.^2).^(3/2),'exps',[-1.5 -1.5]);
h = diff(f)-g;
pass = norm(h.vals) < 500*tol;
