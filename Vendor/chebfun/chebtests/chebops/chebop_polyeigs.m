function pass = chebop_polyeigs
% Test the chebop polyeigs method.
% Nick Hale, july 2011

%Tolerance
tol = 1e5*chebfunpref('eps');

% Precomputed.
precomp = [   
   1.359355061649265
  -1.876033230374035
   3.000000000000368
  -3.537162428575435
   4.643868772821693
  -5.186237295747643];

%% With linops
d = domain(-1,1);
x = chebfun(@(x) x, d);
A = diff(d,2); A.lbc = 0; A.rbc = 0;
B = -diag(x)*diff(d);
C = eye(d);
[V D] = polyeigs(A,B,C,6,0);
err(1) = norm(D-precomp,inf);
err(2) = norm((A+D(1,1)*B+D(1,1)^2*C)*V(:,1));

%% With chebops
A = chebop(@(x,u) diff(u,2),[-1 1],'dirichlet');
B = chebop(@(x,u) -x.*diff(u));
C = chebop(@(x,u) u);
[V D] = polyeigs(A,B,C,6,0);
err(3) = norm(D-precomp,inf);
v = V(:,1);
err(4) = norm((A(x,v)+D(1,1)*B(x,v)+D(1,1)^2*C(x,v)));

%% Pass?
pass = err < tol*[1 100 1 100];


