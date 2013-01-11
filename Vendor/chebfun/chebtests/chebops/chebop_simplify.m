function pass = chebop_simplify
% This test has a purpose: to make sure that the
% nonlinop backslash process succeeds in simplifying
% a solution which is a parabola to a chebfun with
% length 3.
%
% Nick T. & Asgeir B., 4 December 2009.

%%
d = [-1 1];
x = chebfun(@(x) x, d);
N = chebop(d);
N.bc = 1;
N.op = @(u) diff(u,2);
u1 = N\2;                    % this should be a parabola
u1 = simplify(u1,1e-10,'force');
pass(1) = (length(u1)==3);

N.op = @(u) diff(u,2) + sin(u-x.^2);
u2 = N\2;                       % this should be a parabola too!
u2 = simplify(u2,1e-10);        % Do the simplification afterwards
pass(2) = (length(u2)==3);
