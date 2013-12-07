function F = vertcat(varargin)
%VERTCAT Vertical concatenation of chebfun2 objects.
%
% [F;G] is the vertical concatenation of chebfun2 objects F and G, and this
% function returns a Chebfun2v. 
% 
% [F;G] is different syntax for VERTCAT(F,G)

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin == 2
    % call the chebfun2v constructor.
    F = chebfun2v(varargin{1},varargin{2});
elseif nargin == 3
    F = chebfun2v(varargin{1},varargin{2});
    F = vertcat(F,varargin{3}); 
else
    error('CHEBFUN2:VERTCAT','Cannot vertically concatenate more than three chebfun2 objects.');
end
    

end