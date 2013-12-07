function h = ldivide(f,g)
%.\   Pointwise chebfun2v left divide.
%
% Left componentwise divide for a chebfun2v. 
%
% See also RDIVIDE.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(f) || isempty(g)
   h = chebfun2v;
   return; 
end


% componentwise divide. 
if isa(f,'chebfun2v') 
    h = f; 
    h.xcheb = ldivide(f.xcheb,g);
    h.ycheb = ldivide(f.ycheb,g);
    h.zcheb = ldivide(f.zcheb,g);
else
    h = g; 
    h.xcheb = ldivide(f,g.xcheb);
    h.ycheb = ldivide(f,g.ycheb);
    h.zcheb = ldivide(f,g.zcheb);
end
    
end