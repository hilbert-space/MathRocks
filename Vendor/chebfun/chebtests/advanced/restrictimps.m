function pass = restrictimps
% Test handling of the imps matrix by restrict
% Rodrigo Platte, December 2008

splitting on

f = chebfun(@(x) sign(x)+sin(x));
g = diff(f);
h = g{-0.8, 0.7};
IM = [[g(-0.8); 0] g.imps(:,2) [g(0.7); 0]];
pass = norm(h.imps - IM) < 10*chebfunpref('eps');
