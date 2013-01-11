function comet3(f,g,h,varargin)
% COMET3   Three-dimensional comet plot.
% 
% A comet graph is an animated graph in which a thick dot (the comet head) 
% traces the data points on the screen. Notice that unlike the standard
% Matlab comet command, the chebfun comet does not leave a trail.
%
% COMET(F,G,H) displays a comet in 3D-space using the three chebfuns as 
% coordinates. COMET(F,G,H,P) when P is a real number will control the 
% speed at which the comet is updated. A larger P will result in a slower plot.
%
% See also chebfun/comet

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

comet(f,g,h,varargin{:});