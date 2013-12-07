function pass = cheblegtransformtest
% Test for the leg2cheb and cheb2leg commands. 
% Nick Hale and Alex Townsend, August 2013. 

tol = 10*eps; % this algorithm is always machine precision
j = 1; 

% Converting the constant function
N = 100; ccheb = [zeros(N-1,1);2];
cleg = cheb2leg(ccheb);     
pass(j) = ( norm(ccheb - cleg, inf) < N*tol); j = j + 1; 
cnew = leg2cheb(cleg);
pass(j) = ( norm(ccheb - cnew, inf) < N*tol); j = j + 1;

% Converting the constant function for large N
N = 1000; ccheb = [zeros(N-1,1);1];
cleg = cheb2leg(ccheb);     
pass(j) = ( norm(ccheb - cleg, inf) < N*tol); j = j + 1; 
cnew = leg2cheb(cleg);
pass(j) = ( norm(ccheb - cnew, inf) < N*tol); j = j + 1;

% Converting the function 'x'
N = 100;ccheb = [zeros(N-1,1);1;0];
cleg = cheb2leg(ccheb);     
pass(j) = ( norm(ccheb - cleg, inf) < N*tol); j = j + 1; 
cnew = leg2cheb(cleg);
pass(j) = ( norm(ccheb - cnew, inf) < N*tol); j = j + 1;

% Is the inverse the inverse? 
N = 100; ccheb = rand(N,1);
cleg = cheb2leg(ccheb);    
cnew = leg2cheb(cleg);
pass(j) = ( norm(ccheb - cnew, inf) < N*tol); j = j + 1;

% Is the inverse the inverse?  For large N
N = 1000; ccheb = rand(N,1);
cleg = cheb2leg(ccheb);     
cnew = leg2cheb(cleg);
pass(j) = ( norm(ccheb - cnew, inf) < N^1.5*tol); j = j + 1;

% Is the inverse the inverse?  For large N
N = 10000; ccheb = rand(N,1);
cleg = cheb2leg(ccheb);     
cnew = leg2cheb(cleg);
pass(j) = ( norm(ccheb - cnew, inf) < N^1.5*tol); j = j + 1;

% Is the inverse the inverse?  For large N
N = 10000; ccheb = (1:N)'.^(-1/2).*rand(10000,1);
cleg = cheb2leg(ccheb);      
cnew = leg2cheb(cleg);
pass(j) = ( norm(ccheb - cnew, inf) < N*tol); j = j + 1;

end