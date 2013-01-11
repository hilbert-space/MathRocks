function pass = ad_vs_diff_trig_deg
% A test that compares derivatives obtained via AD to derivatives obtained
% with the normal diff of the chebfun system.
% More specifically, it tests whether the trigonometric and hyperbolic 
% functions are differentiated correctly.
% This test works with trigonometric functions where the chebfuns are in degrees.

d = [0.1,0.9];
x = chebfun(@(x) x, d);
cheb1 = chebfun(1,d);
norms = zeros(1,12);

% Inverse trigonometric and hyperbolic functions
norms(1) = norm(diag(diff(acosd(x),x))-diff(acosd(x)));

norms(2) = norm(diff(acotd(x),x)*cheb1-diff(acotd(x)));

norms(3) = norm(diff(acscd(x),x)*cheb1-diff(acscd(x)));

norms(4) = norm(diff(asecd(x),x)*cheb1-diff(asecd(x)));

norms(5) = norm(diff(asind(x),x)*cheb1-diff(asind(x)));

norms(6) = norm(diff(atand(x),x)*cheb1-diff(atand(x)));

% Trigonometric and hyperbolic functions

norms(7) = norm(diag(diff(cosd(x),x))-diff(cosd(x)));

norms(8) = norm(diff(cotd(x),x)*cheb1-diff(cotd(x)));

norms(9) = norm(diff(cscd(x),x)*cheb1-diff(cscd(x)));

norms(10) = norm(diff(secd(x),x)*cheb1-diff(secd(x)));

norms(11) = norm(diff(sind(x),x)*cheb1-diff(sind(x)));

norms(12) = norm(diff(tand(x),x)*cheb1-diff(tand(x)));

pass = norms < chebfunpref('eps')*1e5;
