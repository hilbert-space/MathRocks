function pass = kroneckerProduct
% This function does outerproduct with * and Kron. 
% Alex Townsend, March 2013. 

tol = max(chebfunpref('eps'),chebfun2pref('eps')); 

j = 1; 

% rank 1 chebfun2. 

f = chebfun(@(x) x.^2);
g = chebfun(@(y) sin(y));
 
h1 = chebfun2(@(x,y) x.^2.*sin(y));
h2 = chebfun2(@(x,y) y.^2.*sin(x)); 


pass(j) = (norm(h1 - kron(f', g)) < 10*tol); j = j + 1; 
pass(j) = (norm(h2 - kron(f, g')) < 10*tol); j = j + 1;
pass(j) = (norm(h1 - g*f') < 10*tol); j = j + 1; 
pass(j) = (norm(h2 - f*g') < 10*tol); j = j + 1;
%%

% different domain in x and y  

d = [-2 pi -pi 2];
f = chebfun(@(x) x.^2, d(1:2));
g = chebfun(@(y) sin(y), d(3:4));
 
h1 = chebfun2(@(x,y) x.^2.*sin(y), d);
h2 = chebfun2(@(x,y) y.^2.*sin(x), [d(3:4) d(1:2)]); 

pass(j) = ( norm(h1 - kron(f', g)) < 10*tol); j = j + 1; 
pass(j) = (norm(h2 - kron(f, g')) < 10*tol); j = j + 1;
pass(j) = ( norm(h1 - g*f') < 10*tol); j = j + 1; 
pass(j) = (norm(h2 - f*g') < 10*tol); j = j + 1;
%% 
% Quasimatrices and rank 4 chebfun2

x = chebfun([-1 1],[-1 1]);
F = [1 x x.^2 x.^4]; 
G = [1 cos(x) sin(x) x.^5]; 

h1 = chebfun2(@(x,y) 1 + x.*cos(y) + x.^2.*sin(y) + x.^4.*y.^5);
h2 = chebfun2(@(x,y) 1 + y.*cos(x) + y.^2.*sin(x) + y.^4.*x.^5);

pass(j) = (norm(h1 - kron(F', G)) < 10*tol); j = j + 1; 
pass(j) = (norm(h2 - kron(F, G')) < 10*tol); j = j + 1;
pass(j) = (norm(h1 - G*F') < 10*tol); j = j + 1; 
pass(j) = (norm(h2 - F*G') < 10*tol); j = j + 1;
%% 
% different domains and quasi matrices 

x = chebfun([-2 1],[-2 1]); 
y = chebfun([-1 1],[-1 1]); 
d = [-2 1 -1 1]; 

F = [1 x x.^2 x.^4]; 
G = [1 cos(y) sin(y) y.^5]; 

h1 = chebfun2(@(x,y) 1 + x.*cos(y) + x.^2.*sin(y) + x.^4.*y.^5,d);
h2 = chebfun2(@(x,y) 1 + y.*cos(x) + y.^2.*sin(x) + y.^4.*x.^5,[d(3:4) d(1:2)]);

pass(j) = (norm(h1 - kron(F', G)) < 10*tol); j = j + 1; 
pass(j) = (norm(h2 - kron(F, G')) < 10*tol); j = j + 1;
pass(j) = (norm(h1 - G*F') < 10*tol); j = j + 1; 
pass(j) = (norm(h2 - F*G') < 10*tol); j = j + 1;
end
