function pass = blowup_splitting
% Check if blowups and splitting play well together.
%
% Nick Trefethen  20/11/2009

tol = chebfunpref('eps');
f = chebfun('tan(x)',[0 5],'splitting','on','blowup',1);
pass = (abs(f(3)-tan(3))<100*tol);
