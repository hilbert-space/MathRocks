function pass = fun2_arithmetic
% Simple arithmetic operations for fun2 objects. 
% Alex Townsend, March 2013. 

% These function chosen so that scl does not change. 
f = @(x,y) cos(x); f=fun2(f); 
g = @(x,y) sin(y); g=fun2(g); 
% exact answers. 
plus_exact = @(x,y) cos(x) + sin(y); plus=fun2(plus_exact); 
minus_exact = @(x,y) cos(x) - sin(y); minus=fun2(minus_exact); 
mult_exact = @(x,y) cos(x).*sin(y); mult=fun2(mult_exact); 

x = linspace(-1,1); [xx yy]=meshgrid(x);
pass(1) = (max( max ( abs( plus_exact(xx,yy) - feval(plus,xx,yy)) ) ) <100*eps);
pass(2) = (max( max ( abs( minus_exact(xx,yy) - feval(minus,xx,yy)) ) ) <100*eps);
pass(3) = (max( max ( abs( mult_exact(xx,yy) - feval(mult,xx,yy)) ) ) <100*eps);
pass = all(pass); 

end