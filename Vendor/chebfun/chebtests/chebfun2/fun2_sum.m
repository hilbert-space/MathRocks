function pass = fun2_sum
% Test for integration of a fun2. 
% Alex Townsend, March 2013. 

% Example from wiki: http://en.wikipedia.org/wiki/Multiple_integral#Double_integral
f = 'x.^2 + 4*y'; 
f = fun2(f,[11 14 7 10]);

exact = 1719;

j=1;
pass(j)  = (abs(integral2(f)-exact)<1e-15);j=j+1;

% check syntax as well. 

f = chebfun2(@(x,y) x); 
pass(j) = norm(sum(f) - chebfun(@(x) 2*x)')<10*eps; j=j+1;
pass(j) = norm(sum(f,1) - sum(f))<10*eps; j = j+1; 
pass(j) = norm(sum(f,2))<10*eps; j = j+1; 


% On different domains. 
f = chebfun2(@(x,y) y,[0 1 -pi pi]); 
pass(j) = norm(sum(f))<10*eps; j=j+1;
pass(j) = norm(sum(f,1) - sum(f))<10*eps; j = j+1; 
pass(j) = norm(sum(f,2)-chebfun(@(x) x,[-pi pi]))<10*eps; j = j+1; 


end