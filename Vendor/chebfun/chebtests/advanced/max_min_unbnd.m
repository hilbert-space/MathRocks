function pass = max_min_unbnd
% Tests max and min of unbounded functions.
% Nick Hale, Feb 2011

tol = 10*chebfunpref('eps');

x = chebfun('x',[-1 0 2]);
g = 1./x;

fmax = max(g,5);
fmaxtrue = chebfun({5,@(x) 1./x,5},[-1 0 .2 2],'exps',[0 0 -1 0 0 0]);
pass(1) = norm(fmax-fmaxtrue) < tol;

fmin = min(g,5);
fmintrue = chebfun({@(x) 1./x,5,@(x) 1./x},[-1 0 .2 2],'exps',[0 -1 0 0 0 0]);
pass(2) = norm(fmin-fmintrue) < tol;

% plot(g,'b',[-1 1],[5 5],'-r'); hold on
% plot(fmax,'--k','linewidth',2); 
% plot(fmin,'--m','linewidth',2); hold off
