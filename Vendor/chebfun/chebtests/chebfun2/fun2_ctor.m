function pass = fun2_ctor
% Check various different ways of calling the fun2 constructor. 
% Alex Townsend, March 2013. 

j=1;
f = @(x,y) cos(x) + sin(x.*y);  % simple function. 
fstr = 'cos(x) + sin(x.*y)'; % string version.

% Check things don't break. 
try 
% % Adaptive calls % % 
f = @(x,y) cos(x); f=fun2(f); 
g = @(x,y) sin(y); g=fun2(g); 
% exact answers. 
plus_exact = @(x,y) cos(x) + sin(y); fun2(plus_exact); 
minus_exact = @(x,y) cos(x) - sin(y); fun2(minus_exact); 
mult_exact = @(x,y) cos(x).*sin(y); fun2(mult_exact); 
% pow_exact = @(x,y) cos(x).^sin(y); pow_exact=fun2(pow_exact); 
pass(j) = 1; 
catch
    pass(j) = 0 ; 
end
j=j+1; 


% Now lets try various calls to fun2 for discrete data. 
A = rand(79,1)*rand(1,31);  
f = fun2(A); 
pass(j) = ( length(f) == 1) ; j=j+1; 

A = A + rand(79,1)*rand(1,31);  
f = fun2(A); 
pass(j) = ( length(f) == 2) ; j=j+1; 

end