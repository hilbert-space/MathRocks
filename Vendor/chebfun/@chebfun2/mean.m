function v = mean(f,varargin)
%MEAN   Average or mean value of a chebfun2. 
% 
%  MEAN(F) takes the mean in the y-direction (default), i.e., 
% 
%          MEAN(F) = 1/(ymax-ymin) sum(F).
%
%  MEAN(F,DIM) takes the mean along the direction DIM. If DIM = 1 it is the
%  y-direction and if DIM = 2 then it is the x-direction. 
%
% See also MEAN2, STD2.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isempty(f) ) % check for empty chebfun2.
    return;
end 

rect = f.corners; 
lx = rect(2)-rect(1); ly = rect(4)-rect(3); % domain lengths.

if ( isempty(varargin) )
    v = 1/ly * sum(f); % mean in the y direction (default)
elseif ( varargin{1} == 2 )
    v = 1/ly * sum(f,varargin{1});% mean in the x direction
elseif ( varargin{1} == 1 )
    v = 1/lx  * sum(f,varargin{1});% mean in the y direction
else
    error('CHEBFUN2:MEAN:DIM','Mean not in x or y direction')
end

end
