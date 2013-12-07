function pass = chebfun2_vectorise
% Check if vectorise flag is working correctly.
% Alex Townsend, March 2013. 

tol = chebfun2pref('eps'); j=1; 

% check vectorise
f1 = chebfun2(@(x,y) x*y,'vectorise'); 
f2 = chebfun2(@(x,y) x.*y,'vectorise'); 
f3 = chebfun2(@(x,y) x.*y); 
f4 = chebfun2(@(x,y) x.*y,[-1 1 -1 1],'vectorise');
f5 = chebfun2(@(x,y) x.*y,[-1 1 -1 1],'vectorise');
pass(j) = norm(f1-f2)<tol; j = j+1; 
pass(j) = norm(f2-f3)<tol; j = j+1; 
pass(j) = norm(f3-f4)<tol; j = j+1; 
pass(j) = norm(f4-f5)<tol; j = j+1; 


% check vectorize
f1 = chebfun2(@(x,y) x*y,'vectorize'); 
f2 = chebfun2(@(x,y) x.*y,'vectorize'); 
f3 = chebfun2(@(x,y) x.*y); 
f4 = chebfun2(@(x,y) x.*y,[-1 1 -1 1],'vectorize');
f5 = chebfun2(@(x,y) x.*y,[-1 1 -1 1],'vectorize');
pass(j) = norm(f1-f2)<tol; j = j+1; 
pass(j) = norm(f2-f3)<tol; j = j+1; 
pass(j) = norm(f3-f4)<tol; j = j+1; 
pass(j) = norm(f4-f5)<tol; j = j+1; 

end