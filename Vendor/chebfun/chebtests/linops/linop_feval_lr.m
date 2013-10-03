function pass = linop_feval_lr
% Check that left/right evaluation with linops behaves as expected.
% Nick Hale, May 2011

% A tolerance to check to
tol = 100*chebfunpref('eps');

d = domain(-1,1);
x = chebfun(@(x) x, d);
s = cos(x+pi/4).*sign(x)+.5;

% Create the linops
L = feval(d,0);
Ll = feval(d,0,'left');
Lr = feval(d,0,'right');

% True left and right points, and an averaged centre point.
cl = -cos(pi/4)+0.5;
cr = cos(pi/4)+0.5;
c = (cl+cr)/2;

% Check the forward operators
pass(1) = abs(L(s)-c)<tol;
pass(2) = abs(Ll(s)-cl)<tol;
pass(3) = abs(Lr(s)-cr)<tol;

% Try the matrix version.
d2 = [-1 0 1];
N = 10*[5 6];
s2 = chebfun({@(x) -cos(x+pi/4)+0.5,@(x) cos(x+pi/4)+.5},[-1 0 1],'N',N);
pass(4) = abs(L(N,d2)*s2.vals - c) < tol;
pass(5) = abs(Ll(N,d2)*s2.vals - cl) < tol;
pass(6) = abs(Lr(N,d2)*s2.vals - cr) < tol;

% And with maps.
m = maps('kte',domain([-1 0]));
m(2) = maps('kte',domain([0 1]));
s3 = chebfun({@(x) -cos(x+pi/4)+0.5,@(x) cos(x+pi/4)+.5},[-1 0 1],'N',N,'map',m);
pass(7) = abs(L(N,m,d2)*s3.vals - c) < tol;
pass(8) = abs(Ll(N,m,d2)*s3.vals - cl) < tol;
pass(9) = abs(Lr(N,m,d2)*s3.vals - cr) < tol;

% Check the derivatives at left and right limits
D = diff(d);
Al = Ll*D;
Ar = Lr*D;
cpl = sqrt(2)/2;
cpr = -sqrt(2)/2;
pass(10) = abs(Al(s)-cpl) + abs(Al(N,d2)*s2.vals-cpl) < 1e3*tol;
pass(11) = abs(Ar(s)-cpr) + abs(Ar(N,d2)*s2.vals-cpr) < 1e3*tol;

