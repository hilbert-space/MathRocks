function pass = subspacetest
% test the subspace function (angle between subspaces). Also calls vander.m
% Rodrigo Platte, October 2008.
% (A Level 2 Chebtest)

pass = true;
d = [0,2*pi];
theta = chebfun(@(theta) theta, d);
A = [1/sqrt(2) cos(theta) sin(2*theta) sin(3*theta)]/sqrt(pi); % orthonormal quasimatrix
f = sin(10*theta)/sqrt(pi);
alpha = [1e-10 pi/5 pi/2-1e-10];
for k = 1:length(alpha)
    B = cos(alpha(k))*A(:,k)+sin(alpha(k))*f;
    angle = subspace(A,B);
    pass(k) = abs(angle-alpha(k)) < 1e3*chebfunpref('eps');
end
