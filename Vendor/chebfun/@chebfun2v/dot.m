function f = dot(F,G)
%DOT  Vector dot product.
% 
% f = dot(F,G) returns the dot product of the chebfun2v objects F and G.
% dot(F,G) is the same as F'*G.
% 
% See also CROSS. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

if ( isempty(F.zcheb) || isempty(G.zcheb) )
    f = F.xcheb .* G.xcheb + F.ycheb .* G.ycheb ;
else
    f = F.xcheb .* G.xcheb + F.ycheb .* G.ycheb + F.zcheb .* G.zcheb;
end

end