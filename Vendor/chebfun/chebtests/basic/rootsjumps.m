function pass = rootsjumps
% Tests the roots of functions with jump discontinuities.
%
% Mohsin Javed, May 2012
% (A Level 0 Chebtest)

x = chebfun('x');
% No root should be returned
r = [roots(1./x,'nojump'), roots(sign(x),'nojump'), ...
     roots(heaviside(x),'nojump', 'nozerofun') ];
% 0 should be returned as a root in each case
z = [roots(1./x), roots(sign(x)), roots(heaviside(x),'nozerofun')];

% pass?
pass = isempty(r) && ~any(z);