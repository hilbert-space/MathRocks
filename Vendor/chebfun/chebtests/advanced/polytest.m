function pass = polytest
% This test check that poly and ployval are working correctly. 
% Rodrigo Platte Feb 2009

c = rand(1,5);
f = chebfun(@(x) polyval(c,x), [-2 10],5);
pass = norm(c - poly(f)) < chebfunpref('eps')*1e5;