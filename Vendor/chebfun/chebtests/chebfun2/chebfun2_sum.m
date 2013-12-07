function pass = chebfun2_sum
% Test for integration of a fun2 object. 
% Alex Townsend, March 2013. 

% Example from wiki: http://en.wikipedia.org/wiki/Multiple_integral#Double_integral
f = 'x.^2 + 4*y'; 
f = chebfun2(f,[11 14 7 10]);

exact = 1719;

pass = (abs(integral2(f)-exact)<1e-15);

end