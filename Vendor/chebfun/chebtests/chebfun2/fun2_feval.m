function pass = fun2_feval
% Check evaluation for fun2 objects. 
% Alex Townsend, March 2013. 

j=1;
f = @(x,y) cos(x) + sin(x.*y); 
fun = fun2(f);
tol = 100*chebfun2pref('eps');

r = 0.126986816293506; s = 0.632359246225410; % two fixed random number in domain.
pass(j) = (abs(f(r,s) - fun.feval(r,s))<tol);j=j+1;

% Are we evaluating on arrays correctly

r = rand(10,1); s = rand(10,1); [rr ss]=meshgrid(r,s);
pass(j) = (norm((f(r,s) - fun.feval(r,s)))<tol);j=j+1;
pass(j) = (norm((f(rr,ss) - fun.feval(rr,ss)))<tol);j=j+1; % on arrays as well. 

% Does this work off [-1,1]^2
fun = fun2(f,[-pi/6 pi/2 -pi/12 sqrt(3)]); % strange domain. 
r = 0.126986816293506; s = 0.632359246225410; % two fixed random number in domain.
pass(j) = (abs(f(r,s) - fun.feval(r,s))<tol);j=j+1;

% Are we evaluating on arrays correctly
r = rand(10,1); s = rand(10,1); [rr ss]=meshgrid(r,s);
pass(j) = (norm((f(r,s) - fun.feval(r,s)))<2*tol);j=j+1;
pass(j) = (norm((f(rr,ss) - fun.feval(rr,ss)))<10*tol);j=j+1; % on arrays as well. 

% Evaluating at Chebyshev points. 
% x = chebpts(length(fun.C)); 
fun = fun2(f); 
pass(j) = abs(fun.feval(0.881921264348355,0.049067674327418) - f(0.881921264348355,0.049067674327418))<tol; j=j+1;
pass(j) = abs(fun.feval(0.881921264348355,0) - f(0.881921264348355,0))<tol; j=j+1; 
pass(j) = abs(fun.feval(pi/6,-0.427555093430282) - f(pi/6, -0.427555093430282))<tol; j=j+1; 

end