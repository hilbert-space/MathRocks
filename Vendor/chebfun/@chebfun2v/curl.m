function s = curl(f)
%CURL curl of a chebfun2v
% 
% S = CURL(F) returns the chebfun2 of the curl of F. If F is a chebfun2v 
% with two components then it returns the chebfun2 representing 
%
%         CURL(F) = F(2)_x - F(1)_y,
%
% where F = (F(1),F(2)).  If F is a chebfun2v with three components then it
% returns the chebfun2v representing the 3D curl operation. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.  

if isempty(f.zcheb)  % do the curl of a 2-vector. 
    fx = f.xcheb; fy = f.ycheb;
    s = diff(fy,1,2) - diff(fx,1,1);
else   % do the curl of a 3-vector.
    fx = f.xcheb; fy = f.ycheb; fz = f.zcheb; 
    xcomponent = diff(fz);  
    ycomponent = -diff(fz,1,2);  
    zcomponent = diff(fy,1,2) - diff(fx,1,1);
    s = f; 
    s.xcheb = xcomponent; 
    s.ycheb = ycomponent; 
    s.zcheb = zcomponent; 
end

end