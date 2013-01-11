function pass = unbndpolys
% Tests both the construction of Laguerre and Hermite polynomials on unbounded
% intervals by lagpoly and hermpoly, and the values returned by lagpts and
% hermpts.
%
% Nick Hale, April 2010
% (A Level 1 Chebtest)

% Otions
N = 8;
tol = 2e-9;

% Laguerre Polynomials
x = linspace(0,10,1000);
L = cell(N+1,1);
L{1} = @(x) 1+0*x;
L{2} = @(x) 1-x;
L{3} = @(x) polyval([1 -4 2]/2,x);
L{4} = @(x) polyval([-1 9 -18 6]/6,x);
L{5} = @(x) polyval([1 -16 72 -96 24]/24,x);
L{6} = @(x) polyval([-1 25 -200 600 -600 120]/120,x);
L{7} = @(x) polyval([1 -36 450 -2400 5400 -4320 720]/720,x);
for k = 6:N-1
    L{k+2} = @(x) ((2*k+1-x).*L{k+1}(x)-k*L{k}(x))/(k+1);
end

J = lagpoly(N);
LNx = L{N+1}(x);Jx = J(x);
pass(1) = norm((LNx-Jx)./LNx,inf) < tol;
pass(2) = norm(L{N+1}(lagpts(N,'fast')),inf) < tol;
% semilogy(abs((LNx-Jx)./LNx))

% Hermite Polynomials
x = linspace(-10,10,1000);
H = cell(N+1,1);
H{1} = @(x) 1+0*x;
H{2} = @(x) 2*x;
H{3} = @(x) 4*x.^2-2;
H{4} = @(x) 8*x.^3-12*x;
H{5} = @(x) 16*x.^4-48*x.^2+12;
H{6} = @(x) 32*x.^5-160*x.^3+120*x;
H{7} = @(x) 64*x.^6-480*x.^4+720*x.^2-120;
H{8} = @(x) 128*x.^7-1344*x.^5+3360*x.^3-1680*x;
H{9} = @(x) 256*x.^8-3584*x.^6+13440*x.^4-13440*x.^2+1680;
H{10} = @(x) 512*x.^9-9216*x.^7+48384*x.^5-80640*x.^3+30240.*x;
H{11} = @(x) 1024*x.^10-23040*x.^8+161280*x.^6-403200*x.^4+302400*x.^2-30240;
for k = 10:N-1
    H{k+2} = @(x) 2*(x.*H{k+1}(x)-k*H{k}(x));
end

J = hermpoly(N,'phys');
HNx = H{N+1}(x); Jx = J(x);
pass(3) = norm((HNx-Jx)./HNx,inf) < tol;
pass(4) = norm(H{N+1}(hermpts(N,'fast')),inf) < tol;
% semilogy(abs((HNx-Jx)./HNx))

