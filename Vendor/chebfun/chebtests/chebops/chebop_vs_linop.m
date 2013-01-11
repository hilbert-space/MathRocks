function pass = chebop_vs_linop
% Chebtest CHEBOP_VS_LINOP
%
% Solves linear BVPs, where problems are set up using both linops and
% chebops, and compares that the same solution is obtained

d = domain(0,2);
x = chebfun('x',d);
D = diff(d); D2 = diff(d,2); I = eye(d); Z = zeros(d);
%% Simple scalar example
% Solving
%   u'' + sin(x)*u = 2*x; u(0) = 1; u(2) = 2;
L = D2 + diag(sin(x));
L.lbc = 1; L.rbc = 2;
ulinop = L\(2*x);

C = chebop(@(x,u) diff(u,2) + sin(x).*u,d,1,2);
uchebop = C\(2*x);

% Those should be exactly the same
pass(1) = norm(ulinop-uchebop) == 0;

% If we include the affine part in the chebop, rather than on the RHS, the
% answers should match exactly again
C2 = chebop(@(x,u) diff(u,2) + sin(x).*u-2*x,d,1,2);
uchebop2 = C2\0;

pass(2) = norm(uchebop-uchebop2) == 0;


%% Coupled system
% Solving
%   u' + x.^2*u+v = 1
%   u+(x+1)*v'    = 2
%
% s.t.
%   u(0) = 1, v(2) = 3;

L = [D + diag(x.^2) I; I  diag(x+1)*D];
bc.left.op = [I Z]; bc.left.val = 1;
bc.right.op = [Z I]; bc.right.val = 3;
L = L & bc;
uvlinop = L\[1 2];

C = chebop(@(x,u,v) [diff(u)+x.^2.*u+v, u + (x+1).*diff(v)],d);
C.lbc = @(u,v) u-1;
C.rbc = @(u,v) v-3;
uvchebop = C\[1 2];

pass(3) = norm(uvlinop-uvchebop) == 0;

