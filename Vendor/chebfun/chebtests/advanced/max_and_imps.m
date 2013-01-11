function pass = max_and_imps
% Tests if max introduces small jumps when computing the maximum
% of two smooth functions. 
% Rodrigo Platte, May 2009.

x = chebfun('x',[0 10]);
f = sin(x) + sin(x.^2);
hat = 1-abs(x-5)/5;
h = max(f,hat);
m = h./sqrt(1+x)+sin(2*x)/10;
mp = diff(m);

pass = size(mp.imps,1) == 1;