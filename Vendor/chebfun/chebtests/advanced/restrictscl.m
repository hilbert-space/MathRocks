function pass = restrictscl

% This function tests the retrict function (problem related to a bug report
% by Justin Kao of MIT.
% Rodrigo Platte, January 2009

tol = chebfunpref('eps');

f = chebfun(@(x)x,[0 1]);
g = f{0.5,1};
pass = norm(g.^-2-(g.^-1./g),inf)<100*tol && g.scl == 1 && norm(g.imps - [0.5 1],inf)<tol;
