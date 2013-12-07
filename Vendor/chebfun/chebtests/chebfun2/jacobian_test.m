function pass = jacobian_test
% Test for chebfun2/jacobian, and chebfun2v/jacobian.
% Alex Townsend, March 2013. 


tol = chebfun2pref('eps'); j = 1; 

%% convert cartesian -> polar
r = chebfun2(@(r,th) r,[0 1 0 2*pi]);
th = chebfun2(@(r,th) th,[0 1 0 2*pi]);

x = r.*cos(th); y = r.*sin(th); 
F = [x;y];
J1 = jacobian(F);
J2 = jacobian(x,y);

% J1 and J2 should be the same! 
pass(j) = ( norm(J1-J2) < tol); j = j+1; 
pass(j) = ( norm(J1-r) < 100*tol ); j = j+1; 


%% Another one. 
u = chebfun2(@(x,y) x.^2 - y.^2) ; 
v = chebfun2(@(x,y) x.*y); 

J1 = jacobian([u;v]);
J2 = jacobian(u,v); 
exact = chebfun2(@(x,y) 2*(x.^2+y.^2)); 

pass(j) = ( norm(J1-J2) < tol); j = j+1; 
pass(j) = ( norm(J1-exact) < 100*tol ); j = j+1; 

end