function f = diag(f,varargin)
%DIAG(F) diagonal of a chebfun2.
%
% G = DIAG(F) returns the chebfun representing g(x) = f(x,x).
%
% G = diag(F,C) returns the chebfun representing g(x) = f(x,x+c).
%
% See also TRACE.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isempty(f) ) % check for empty chebfun2.
return; 
end 

if ( nargin == 1) % diagonal shift if zero. 
c = 0; 
end
if (nargin >= 2 )
    c = varargin{1};
    if ( ~isa(c,'double') )
        error('CHEBFUN2:DIAG','Second argument to diag should be a double.');
    end
end

rect = f.corners;
dom = [max(rect(1),rect(3)-c) min(rect(2),rect(4)-c)];% find domain of diagonal.
f = chebfun(@(x) feval(f,x,x+c),dom);   % construct the diagonal. 

end