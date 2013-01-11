function pass = cumsumunbnd
% Test CUMSUM for chebfuns that have negative, and possibly
% non-integer exponents. This operation is fragile in such 
% situations.

chebfunpref('factory');
tol = 2e-10;

doplot = 0;

f = chebfun('(sin(1-x)-(1-x))./(1-x).^2',[1 4],'exps',[-2 0]);
u = cumsum(f);
a = f.ends(1) + .01;
h = cumsum(f{a,f.ends(2)})+u(a);
if doplot, subplot(4,2,1), plot(u,'b',h,'--g'), end
err = h - restrict(u,[a f.ends(2)]);
nerr(1) = norm(err,inf);
pass(1) = nerr(1) < tol;

f = chebfun('sin(x)./x.^2',[-3 0],'exps',[0 -2]);
u = cumsum(f);
b = f.ends(2) - .01;
h = cumsum(f{f.ends(1), b})+u(f.ends(1));
if doplot, subplot(4,2,2),plot(u,'b',h,'--g'), end
err = h - restrict(u,[f.ends(1) b]);
nerr(2) = norm(err,inf);
pass(2) = nerr(2) < tol;

f = chebfun('1./(1+x)',[-1 4],'exps',[-1 0]);
u = cumsum(f);
xx = .9*linspace(f.ends(1),f.ends(2));
h = log(1+xx);
h = h-h(end)+u(xx(end));
if doplot, 
    subplot(4,2,3), plot(u,'b'); hold on
    plot(xx,h,'--g'); hold off
end
err = u(xx) - h;
nerr(3) = norm(err,inf);
pass(3) = nerr(3) < tol;

f = chebfun('sin(x)./(1+x)',[-1 0],'exps',[-1 0]);
u = cumsum(f);
a = f.ends(1) + .05;
h = cumsum(f{a, f.ends(2)})+u(a);
if doplot, subplot(4,2,4), plot(u,'b',h,'--g'), end
err = h - restrict(u,[a f.ends(2)]);
nerr(4) = norm(err,inf);
pass(4) = nerr(4) < tol;

f = chebfun('sin(x)./(1-x)',[0 1],'exps',[0 -1]);
u = cumsum(f);
b = f.ends(2) - .05;
h = cumsum(f{f.ends(1), b})+u(f.ends(1));
if doplot, subplot(4,2,5), plot(u,'b',h,'--g'), end
err = h - restrict(u,[f.ends(1) b]);
nerr(5) = norm(err,inf);
pass(5) = nerr(5) < tol;

f = chebfun({'exp(2*x)+pi','1./(1-x).^2'},[-1 0 1],'exps',[0 0 -2]);
u = cumsum(f);
b = f.ends(end) - .01;
h = cumsum(f{f.ends(1), b})+u(f.ends(1));
if doplot, subplot(4,2,6), plot(u,'b',h,'--g'), end
err = h - restrict(u,[f.ends(1) b]);
nerr(6) = norm(err,inf);
pass(6) = nerr(6) < tol;

f = chebfun(@(x) 1./(x+1).^(1.8),'exps',[-1.8 0]);
u = cumsum(f);
a = f.ends(1) + .1;
h = cumsum(f{a, f.ends(2)})+u(a);
xx = linspace(a,f.ends(2));
if doplot, subplot(4,2,7), plot(u,'b',h,'--g'), end
err = h(xx)-u(xx);
nerr(7) = norm(err,inf);
pass(7) = nerr(7) < tol;

f = chebfun('sin(pi*exp(x))./(4-x.^2).^2',[-2 2],'exps',[-2 -2]);
u = cumsum(f);
a = f.ends(1) + .1;
b = f.ends(end) - .01;
h = cumsum(f{a, b}); 
h = h - h(0)+u(0);
xx = linspace(a,b);
if doplot, subplot(4,2,8), plot(u,'b',h,'--g'), end
err = h(xx)-u(xx);
nerr(8) = norm(err,inf);
pass(8) = nerr(8) < tol;



