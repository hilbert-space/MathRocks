function pass = convtest
% Test convolution function
% Kuan Xu, November 2012

% Construct a few chebfun objects for the test.

f = chebfun('x',[-1 1]);
g = chebfun('sin(5*x)',[2 4]);
h = chebfun('cos(2*x)',[-3 1]);

p = chebfun('sin(15*x)',[-1 1]);
q = chebfun('exp(cos(3*x))',[-1 1]);

% Set the tolerance
tol = 100 * chebfunpref('eps') * max(norm(f, inf), norm(g, inf));

%% 1. test the commutativity
H1 = conv(f,g);
H2 = conv(g,f);

pass(1) = norm(H1-H2) < tol;

%% 2. test the associativity
H1 = conv(conv(f,g),h);
H2 = conv(f,conv(g,h));

pass(2) = norm(H1-H2) < tol;

%% 3. test the distributivity

H1 = conv(f,(p+q));
H2 = conv(f,p)+conv(f,q);

pass(3) = norm(H1-H2) < tol;