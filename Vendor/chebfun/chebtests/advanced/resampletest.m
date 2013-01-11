function pass = resampletest

% Test if the resampling option is working by counting the number of
% function evaluations
% Rodrigo Platte, June 2009.

global count % counts the number of evaluations

count = 0;
fon = chebfun(@myfun,'resampling','on','exps',[0 0]);
counton = count;

count = 0;
foff = chebfun(@myfun,'resampling','off','exps',[0 0]);
countoff = count;

% Number of evaluations
pass(1) = counton > 1.9*countoff;
% Chebfun representations must match
pass(2) = norm(fon-foff,inf) < chebfunpref('eps')*1e3;


function y = myfun(x)

global count
count = count + length(x);
y = sin(100*x);


