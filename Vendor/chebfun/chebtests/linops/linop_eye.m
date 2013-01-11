function pass = linop_eye

% Checks the 10 by 10 realization of the identity operator.
% (A Level 3 chebtest)

d = domain(0,4);
I = eye(d);
pass = norm(I(10)-eye(10)) < eps;
