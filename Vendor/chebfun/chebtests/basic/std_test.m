function pass = std_test
% Check that std of a complex chebfun gives the correct real result.
% (A Level 0 chebtest)
% Nick Hale, May 2010

tol = chebfunpref('eps');
f = chebfun('1+2i + sqrt(x)','splitting','on',[-1 0 1]);
err = std(f) - sqrt(5/18);
pass(1) = err < tol;
