function g = median(f,varargin)
%MEDIAN  Median value of a chebfun2
%
% G = MEDIAN(F) returns a chebfun G representing the median of the
% chebfun2 along the y direction, i.e
%
%   G = @(x) median( F ( x, : ) )
%
% G = MEDIAN(F,DIM) returns a chebfun G representing the median of F
% along the direction given by DIM, i.e. y-direction if DIM=1 and
% x-direction if DIM = 2.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.


if ( isempty(f) ) % check for empty chebfun2.
    return;
end

if ( nargin==1 ) % default to along the y direction.
    dim=1;
end
if ( nargin==2 ) % take user defined direction.
    dim = varargin{1};
end

sample = 2.^floor(log2(chebfun2pref('minsample')))+1;
tol = chebfun2pref('eps');
rect = f.corners;
happy = 0 ;

% We do not know how to achieve this in an efficient way so
% we are just going to the do the tensor product median.
% It's a little slow.

while ( sample < 2e3 && ~happy )
    x=chebpts(sample,rect(1:2)); y=chebpts(sample,rect(3:4));
    [xx yy]=meshgrid(x,y);
    X = feval(f,xx,yy);
    mX = median(X,dim); mX = mX(:); % make column vector
    c = chebfft(mX);
    if (abs(c(1:8))<10*tol) % happy yet?
        happy=1;
    end  
    sample = 2.^(floor(log2(sample))+1)+1; % increase sample size.
end

if ( dim == 1 )
    interval=rect(1:2);
else
    interval=rect(3:4);
end

g = simplify(chebfun(mX,interval));  % form chebfun.

end