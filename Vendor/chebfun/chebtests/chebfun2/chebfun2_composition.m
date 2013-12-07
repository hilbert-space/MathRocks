function pass = chebfun2_composition
% Test to see if object composition is working. 
% Alex Townsend, March 2013. 

tol = chebfun2pref('eps'); j=1; 

f = chebfun2(@(x,y) sin(10*x.*y),[-1 2 -1 1]);

pass(j) = (norm(f+f+f+f+f+f+f-7*f) < 100*tol); j=j+1; 
pass(j) = (norm(f.*f-f.^2) < 100*tol); j=j+1; 
pass(j) = (norm(f.*f.*f-f.^3) < 100*tol); j=j+1; 


f = chebfun2(@(x,y) sin(10*x.*y)+2,[-1 2 -1 1]);
pass(j) = (norm(sqrt(f.^2)-f) < 100*tol); j=j+1; 

end