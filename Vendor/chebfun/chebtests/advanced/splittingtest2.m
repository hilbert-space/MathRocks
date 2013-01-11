function pass = sinx

% (by Rodrigo Platte)
% This test constructs a chebfun from a complicated
% function that gets split into 8 pieces.
% It checks that the pieces all have equal length.
% (A Level 1 chebtest)

f = chebfun(@(x) sin(x), [0 1e3],'splitting','on');
pass = all(diff(diff(f.ends)) == 0);
