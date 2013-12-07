function h = mrdivide(f,g)
%/   Chebfun2v right divide.
%
% F/c divides each component of a chebfun2v by a scalar. 
% 
% Only allowed to divide by scalars. 
% 
% See also MLDIVIDE.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isempty(f) || isempty(g)
   h = chebfun2v;
   return; 
end

if ~isa(g,'double') && ~isa(g,'chebfun2')
   error('CHEBFUN2:MRDIVIDE:NONSCALAR','Division must be by a scalar.'); 
end


% componentwise divide. 
if isa(f,'chebfun2v') && isa(g,'double')
    h = f; 
    h.xcheb = mrdivide(f.xcheb,g);
    h.ycheb = mrdivide(f.ycheb,g);
    h.zcheb = mrdivide(f.zcheb,g);
elseif isa(f,'chebfun2v') && isa(g,'chebfun2')
    h = f; 
    h.xcheb = rdivide(f.xcheb,g);
    h.ycheb = rdivide(f.ycheb,g);
    h.zcheb = rdivide(f.zcheb,g);
end
    
end