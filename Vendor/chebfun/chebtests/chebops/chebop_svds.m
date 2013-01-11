function pass = chebop_svds
% Test the chebop svds method.
% Nick Hale, August 2011

tol = 1e-9;

%% SVD of a Fredholm operator
d = [0,pi];
x = chebfun(@(x) x, d);
F = chebop(@(u) fred(@(x,y) sin(x-y),u), d);
S = svds(F);

pass(1) = numel(S) == 2 && norm(S - pi/2) < tol;

return

%% Skip these for speed

%% SVD of D and Eigs of D2
D1 = chebop(@(u) diff(u));
[U S V] = svds(D1,6,1);
s = diag(S);

D2 = chebop(@(u) -diff(u,2),'dirichlet','dirichlet');
[V D] = eigs(D2,6,1);
e = flipud(sqrt(diag(D)));

pass(2) = norm(s-e,inf) < tol;


%% SVD of D2 with boundary conditions
[U S V] = svds(D2,6,1);
s = 2*sqrt(diag(S))/pi;

pass(3) = norm(s-(1:6)',inf) < tol;

%% System
N = chebop(@(x,u,v) [diff(u)+v, diff(v)-u]);
[U S V] = svds(N,6,1);
s = 2*diag(S)/pi;

pass(4) = norm(s-round(3:-.5:.5)',inf) < tol;

%% System with boundary conditions
N.lbc = @(u,v) u;
N.rbc = @(u,v) v;
[U S V] = svds(N,6,1);
err = chebfun;
x = chebfun('x');
for k = 1:6
    err(:,[2*k-1 2*k]) = N(x,V{1}(:,k),V{2}(:,k))-S(k,k)*[U{1}(:,k) U{2}(:,k)];
end
pass(5) = norm(err) < 5e-5;

%% Piecewise problem
D2 = chebop(@(u) -diff(u,2),[-1 0 1]);
D2.bc = 'dirichlet';
[U S V] = svds(D2,6,1);
s = 2*sqrt(diag(S))/pi
norm(s-(1:6)',inf)
pass(6) = norm(s-(1:6)',inf) < 10*tol

%% Piecewise system
