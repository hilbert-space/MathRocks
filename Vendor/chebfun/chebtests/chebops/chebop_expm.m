function pass = chebop_expm
% Test the chebop expm method.
% Asgeir Birkisson, December 2010

tol = 1e-11;

%% With linops
d = domain(-1,1);  x = chebfun('x',d);
D = diff(d);  A = D^2 & 'dirichlet';
f = exp(-20*(x+0.3).^2);
t = [0.001 0.01 0.1 0.5 1];
for tCounter = 1:length(t);
    E = expm(t(tCounter)*A);
    Ef1(:,tCounter) = E*f;
end

%% With chebops
d = [-1,1];  x = chebfun('x',d);
N = chebop(d);
N.op = @(u) diff(u,2);
N.bc = 'dirichlet';
for tCounter = 1:length(t);
    E = expm(t(tCounter)*N);
    Ef2(:,tCounter) = E*f;
end

%% Check

stored_solution = [ 0.000000866635654
                    0.000175829930783
                    0.062297897248372
                    0.060717569924507
                    0.018248085802290].';

pass(1) = norm(stored_solution-Ef1(.567,:)) < tol;
pass(2) = norm(stored_solution-Ef2(.567,:)) < tol;
pass(3) = norm(Ef1-Ef2) < tol;
