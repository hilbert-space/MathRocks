function pass = chebfun2v_syntax
% Check the Chebfun2v constructor for different syntax. 
% Alex Townsend, March 2013. 

pass = 1; 
f = @(x,y) cos(x) + sin(x.*y);  % simple function. 
g = @(x,y) cos(x.*y); 
fstr = 'cos(x) + sin(x.*y)'; % string version.
gstr = 'cos(x.*y)';

try 
% % Adaptive calls % % 
% Operator way 
chebfun2v(f,g);
% String
chebfun2v(fstr,gstr);
% With domain. 
chebfun2v(f,g,[-1 1 1 2]);
% With half domain. 
% chebfun2v(f,g,[-1 2]);
% Split domain syntax
% chebfun2v(f,g,[-1,0],[2,3]);
catch
    pass = 0 ; 
end
end