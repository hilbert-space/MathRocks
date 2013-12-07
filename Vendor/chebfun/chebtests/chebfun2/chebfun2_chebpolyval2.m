function pass = chebfun2_chebpolyval2()
% Check the chebpolyval2 commands in trunk and @chebfun2 folder 
% Alex Townsend, June 2013. 

tol = 100*chebfun2pref('eps');
j = 1; 

% check the trunk chebpolyval2 command.
T = chebpoly(20); 
[xx,yy]=meshgrid(chebpts(100)); 
A = T(xx).*T(yy);  

C = zeros(100); C(end-20,end-20)=1;   
X = chebpolyval2(C); 
pass(j) = ( norm(A - X) < 10*tol); j = j+1; 


% check the @chebfun2/chebpolyval2 command.
f = chebfun2(@(x,y) cos(x.*y)); 
[A1,A2,A3] = chebpolyval2(f); 
X = chebpolyval2(f); 
pass(j) = ( norm(X - A1*A2*A3) < tol); j = j+1; 

end