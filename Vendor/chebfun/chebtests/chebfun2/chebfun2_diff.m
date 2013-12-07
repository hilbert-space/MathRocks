function pass = chebfun2_diff
% Check for Chebfun2 differentiation. 
% Alex Townsend, March 2013. 

% Simple example. 
f = chebfun2(@(x,y) x); j=1;
fy = diff(f,1,1); pass(j) = (abs(fy(pi/6,pi/12)) < 1e-14); j=j+1; 
fx = diff(f,1,2); pass(j) = (abs(fx(pi/6,pi/12)-1) < 1e-14); j=j+1; 

% harder. 
f = chebfun2(@(x,y) cos(x).*exp(y));  g = chebfun2(@(x,y) -sin(x).*exp(y));
fx = diff(f,1,2); pass(j) = (abs(fx(pi/6,pi/12)-g(pi/6,pi/12)) < 1e-14); j=j+1; 

% On different domain. 
f = chebfun2(@(x,y) x, [-1 2 -pi/2 pi]); 
fy = diff(f,1,1); pass(j) = (abs(fy(0,0)) < 1e-14);  j=j+1; 
fx = diff(f,1,2); pass(j) = (abs(fx(0,0)-1) < 1e-14); j=j+1; 

% Check different syntax. 
f = chebfun2(@(x,y) cos(x.*y)); 
g1 = diff(f,2,1); g2 = diff(f,2);
pass(j) =  (abs(g1(pi/6,pi/12) - g2(pi/6,pi/12)) < 1e-14);  j=j+1;


if all(pass)
    pass=1; 
end

end