function pass = ad_vs_diff_special
% A test that compares derivatives obtained via AD to derivatives obtained
% with the normal diff of the chebfun system.
% More specifically, tests special functions such as bessel, airy, ellipj,
% erf*, logarithmic/exponential and powers.

d = [0.1,0.9];
x = chebfun(@(x) x, d);
cheb1 = chebfun(1,d);
norms = zeros(1,20);

% Inverse trigonometric and hyperbolic functions
norms(1) = norm(diag(diff(airy(2,x),x))-diff(airy(2,x)));
norms(2) = norm(diff(besselj(2,x),x)*cheb1-diff(besselj(2,x)));

% Complex conjugate
xi2 = 1i*x.^2;
norms(3) = norm(diff(xi2,x)*cheb1-diff(xi2));

% Elliptic functions
[sn,cn,dn] = ellipj(x,0.5);
norms(4) = norm(diff(sn,x)*cheb1-diff(sn));
norms(5) = norm(diff(cn,x)*cheb1-diff(cn));
norms(6) = norm(diff(dn,x)*cheb1-diff(dn));

% Error functions
norms(7) = norm(diff(erf(x),x)*cheb1-diff(erf(x)));
norms(8) = norm(diff(erfc(x),x)*cheb1-diff(erfc(x)));
norms(9) = norm(diff(erfcx(x),x)*cheb1-diff(erfcx(x)));
norms(10) = norm(diff(erfinv(x),x)*cheb1-diff(erfinv(x)));

% exp and log
norms(11) = norm(diff(exp(x),x)*cheb1-diff(exp(x)));
norms(12) = norm(diff(expm1(x),x)*cheb1-diff(expm1(x)));
norms(13) = norm(diff(log(x),x)*cheb1-diff(log(x)));
norms(14) = norm(diff(log2(x),x)*cheb1-diff(log2(x)));
norms(15) = norm(diff(log10(x),x)*cheb1-diff(log10(x)));
norms(16) = norm(diff(log1p(x),x)*cheb1-diff(log1p(x)));

% power
norms(17) = norm(diff(x.^x,x)*cheb1-diff(x.^x));
norms(18) = norm(diff(x.^2,x)*cheb1-diff(x.^2));
norms(19) = norm(diff(2.^x,x)*cheb1-diff(2.^x));

% sqrt
norms(20) = norm(diff(sqrt(x),x)*cheb1-diff(sqrt(x)));

pass = norms < chebfunpref('eps')*1e3;
