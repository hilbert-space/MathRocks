function pass = chebfun2_cumsum
% check for cumulative summation. 
% Alex Townsend, March 2013. 

tol = chebfun2pref('eps'); 
j = 1; 


% three very simple examples. 

f = chebfun2(@(x,y) x); 
g = cumsum(f); 
pass(j) = ( norm(g - chebfun2(@(x,y) x.*(y+1))) < tol); j = j + 1; 

g = cumsum(f,2); 
pass(j) = ( norm(g - chebfun2(@(x,y) x.^2/2 - 1/2)) < tol); j = j + 1; 

f = chebfun2(1); 
g = cumsum2(f); 
pass(j) = ( norm(g - chebfun2(@(x,y) (x+1).*(y+1))) < tol); j = j + 1; 

end