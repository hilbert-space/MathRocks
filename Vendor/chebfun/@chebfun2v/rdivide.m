function h = rdivide(f,g)
%./   Pointwise chebfun2v right divide.
%
% Right componentwise divide for a chebfun2v. 
%
% See also LDIVIDE.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(f) || isempty(g)
   h = chebfun2v;
   return; 
end


% componentwise divide. 
if isa(f,'chebfun2v') 
    h = f; 
    h.xcheb = rdivide(f.xcheb,g);
    h.ycheb = rdivide(f.ycheb,g);
    h.zcheb = rdivide(f.zcheb,g);
else
    h = g; 
    h.xcheb = rdivide(f,g.xcheb);
    h.ycheb = rdivide(f,g.ycheb);
    h.zcheb = rdivide(f,g.zcheb);
end
    
end