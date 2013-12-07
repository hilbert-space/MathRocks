function f = cross(F,G)
%CROSS  Vector cross product.
%
% f = cross(F,G) returns the cross product of the chebfun2v objects
% F and G. If F and G both have two components then it returns the chebfun2 
% representing
% 
%   CROSS(F,G) = F(1)*G(2) - F(2)*G(1)
% 
% where F = (F(1);F(2)) and G = (G(1); G(2)).  If F and G have three
% components then it returns the chebfun2v representing the 3D cross
% product. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

if ( isempty(F.zcheb) && isempty(G.zcheb) )  % no third component then return the 2D curl. 
    f = F.xcheb .* G.ycheb - F.ycheb.*G.xcheb;  % chebfun2 object. 
elseif ( ~isempty(F.zcheb) && ~isempty(G.zcheb) )
    f = F; 
    xcomponent = F.ycheb .* G.zcheb - F.zcheb.*G.ycheb;
    ycomponent = F.zcheb .* G.xcheb - F.xcheb.*G.zcheb;
    zcomponent = F.xcheb .* G.ycheb - F.ycheb.*G.xcheb;
    f.xcheb = xcomponent;
    f.ycheb = ycomponent;
    f.zcheb = zcomponent;
else
    error('CHEBFUN2V:CROSS','Chebfun2v objects must be both 2- or 3-vectors.');
end

end