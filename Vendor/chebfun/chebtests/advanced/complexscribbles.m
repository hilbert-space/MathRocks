function pass = scribbles
% scribbles.m - uses "scribble" to test various things
%    related to piecewise defined complex chebfuns
%    Nick Trefethen November 2009
% (A Level 1 Chebtest)

f = scribble('rex');
pass(1) = (norm(f)==norm(f'));
pass(2) = max(imag(f))==-min(imag(f'));
pass(3) = (norm(f,inf)-norm([f;f],inf)) < 2^(-50);
