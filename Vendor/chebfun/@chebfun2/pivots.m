function p = pivots(f,varargin)
%PIVOTS  pivot values of a chebfun2
% 
% PIVOTS(F) returns the pivot values taken during in the constructor by the 
%  Gaussian elimination algorithm. 
% 
% PIVOTS(F,'normalise'), returns the normalised pivot values.  These
% numbers are scaled so that the columns and rows have unit 2-norm. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

mode = chebfun2pref('mode'); 
rect = f.corners;

if ( nargin < 2 )
    p= f.fun2.U.';  % just return the pivot values as they are. 

elseif ( strcmpi(varargin{1},'normalise') ... 
                               || strcmpi(varargin{1},'normalize') )
    if ( ~mode )
        % need to make everything continuous.
        C = chebfun(f.fun2.C,rect(3:4));
        R = chebfun(f.fun2.R.',rect(1:2));
    else
        C = f.fun2.C; R = f.fun2.R.';
    end
    cscl = sqrt(sum(C.^2)); rscl = sqrt(sum(R.^2));
    p = f.fun2.U; 
    p = p.*cscl.*rscl; p = p(:);   % normalised pivots. 
else
    error('CHEBFUN2:PIVOTS:InPuts','Unrecognised second argument');
end
end