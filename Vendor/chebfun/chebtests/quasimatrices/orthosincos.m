function pass = orthosincos
% This test constructs a system of chebfuns and checks they have been
% constructed correctly by checking an orthogonality condition.
% TAD

S = []; C = [];
for n = 1:5
  S = [S chebfun(@(x) sin(n*x),[0 2*pi])];
  C = [C chebfun(@(x) cos(n*x),[0 2*pi])];
end
ip = S'*C;
pass = norm(ip) < 100*eps;

end
