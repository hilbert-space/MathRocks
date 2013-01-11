function pass = callpref
% Check if options passed to the constructor are handled correctly.
%
% Rodrigo Platte, May 2009

f = chebfun(@(x) sign(x-0.5), [-2 3], 'splitting', 1, 'minsamples', 5);
pass(1) = f(0) == -1;
pass(2) = f(0.5) == 0;
pass(3) = f(1) == 1;
pass(4) = length(f) == 2;

f = chebfun(@(x) sin(100*x), 'splitting', 1, 'splitdegree', 32);
for k = 1:numel(f.funs)
    pass(k+4) = f.funs(k).n <32;
end
