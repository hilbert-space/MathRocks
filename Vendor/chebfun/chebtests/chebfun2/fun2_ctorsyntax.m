function pass = fun2_ctorsyntax
% This tests the fun2 constructor for different syntax.
% Alex Townsend, March 2013. 

pass = 1; 
f = @(x,y) cos(x) + sin(x.*y);  % simple function. 
fstr = 'cos(x) + sin(x.*y)'; % string version.

try 
% % Adaptive calls % % 
% Operator way 
fun2(f);
% String
fun2(fstr);
% With domain. 
fun2(f,[-1 1 1 2]);
% Split domain syntax
fun2(f,[-1,0],[2,3]);
% Operator only in one variable. 
fun2(@(x,y) x);
catch
    pass = 0 ; 
end
end