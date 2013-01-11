function pass = plotrow
% This test checks that row chebfuns can be plotted
% Rodrigo Platte, Ricardo Pachon

x = chebfun(@(x) x);
figure, plot([x x.^2 x.^3].','.-r'), close
pass = true;
