function pass = chebfun2_ctor
% This tests the chebfun2 constructor does not crash when doing 
% simple arithmetic operations.
% Alex Townsend, March 2013. 

pass = 1; 
f = @(x,y) cos(x) + sin(x.*y);  % simple function. 
fstr = 'cos(x) + sin(x.*y)'; % string version.

try 
% % Adaptive calls % % 
f = @(x,y) cos(x); f=chebfun2(f); 
g = @(x,y) sin(y); g=chebfun2(g); 
% exact answers. 
plus_exact = @(x,y) cos(x) + sin(y); chebfun2(plus_exact); 
minus_exact = @(x,y) cos(x) - sin(y); chebfun2(minus_exact); 
mult_exact = @(x,y) cos(x).*sin(y); chebfun2(mult_exact); 
pow_exact = @(x,y) cos(x).^sin(y); chebfun2(pow_exact); 

catch
    pass = 0 ; 
end
end