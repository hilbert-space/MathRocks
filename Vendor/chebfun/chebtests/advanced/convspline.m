function pass = convspline

% Generates piecewise polynomial cardinal B-splines by a process 
% of convolution, with CONV, then estimates the error compared 
% to the exact solution B, using Chebfun's NORM command.
%
% For more on generating B-splines using convolution, see e.g. 
% http://en.wikipedia.org/wiki/B-spline 

B = (1/6)*chebfun( {'(2+x).^3','1+3*(1+x)+3*(1+x).^2-3*(1+x).^3',...
  '1+3*(1-x)+3*(1-x).^2-3*(1-x).^3','(2-x).^3'}, -2:2 );

s = chebfun(1,[-.5 .5]);
f = s;
for k = 1:3, f = conv(f,s); end

pass = norm( f-B ) < 1e-14*chebfunpref('eps')/eps;

end
