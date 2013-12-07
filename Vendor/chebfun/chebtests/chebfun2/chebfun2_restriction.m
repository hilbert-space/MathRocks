function pass = chebfun2_restriction
% This script checks the restriction of a chebfun2 to a smaller domain. 
% Alex Townsend, March 2013. 

tol  = chebfun2pref('eps');  j = 1; 

% Restricting a chebfun2 to a point. 
f = @(x,y) exp(-10*(x.^2+y.^2));
g = chebfun2(f); 
val = g{0,0,0,0};  % should be f(0,0); 
pass(j) = (abs(val - f(0,0)) < 100*tol); j=j+1; 

% Restricting a chebfun2 to a chebfun.
f = @(x,y) exp(-10*(x.^2+y.^2));
g = chebfun2(f); 
val = restrict(g,chebfun(@(t) t + 1e-18*1i));  % should be f(x,1e-18); 
pass(j) = (norm(val - chebfun(@(x) f(x,1e-18))) < 100*tol);j=j+1;  

% Using subrefs for restricting
f = @(x,y) exp(-10*(x.^2+y.^2));g = chebfun2(f); 
ref.type='()'; ref.subs={pi/6 ':'}; 
val = subsref(g,ref); exact = chebfun(@(y) f(pi/6,y));
pass(j) = (norm(val - exact) < 100*tol); j=j+1; 

end