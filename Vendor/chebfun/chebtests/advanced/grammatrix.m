function pass = grammatrix
% Construct the Gram matrix with chebfuns and 
% compare it to Hilbert matrix.

A = chebfun;
x = chebfun(@(x) x,[0,1]);
for n=1:4
  A(:,n) = x.^(n-1);
end
G = A'*A;
pass = norm(G-hilb(4)) < 10*eps;

end
