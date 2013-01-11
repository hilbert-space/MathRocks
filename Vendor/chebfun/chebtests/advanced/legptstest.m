function pass = legptstest
% This tests checks legpts and the accuracy of the method GW and FAST

% Nick Hale  22/04/2009. (Updated 02/08/2011)
tol = 50*eps;

N = 32;
[x1 w1 v1] = legpts(N,'GW');
[x2 w2 v2] = legpts(N,'fast');
[x3 w3 v3] = legpts(N,'fastsmall');
pass(1) = norm(x1-x2,inf) + norm(w1-w2,inf) + norm(v1-v2,inf) < tol;
pass(2) = norm(x2-x3,inf) + norm(w2-w3,inf) + norm(v2-v3,inf) < tol;

N = 129;
[x1 w1 v1] = legpts(N,'GW');
[x2 w2 v2] = legpts(N,'fast');
[x3 w3 v3] = legpts(N,'fastsmall');
pass(3) = norm(x1-x2,inf) + norm(w1-w2,inf) + norm(v1-v2,inf) < 10*tol;
pass(4) = norm(x2-x3,inf) + norm(w2-w3,inf) + norm(v2-v3,inf) < tol;

% integrate first 30 (even) powers of x correctly?
pass(5) = true;
for j = 2:2:30
    pass(5) = pass(5) && 2/sum(w2*(x2.^j))-(j+1) < 10000*tol;
end




