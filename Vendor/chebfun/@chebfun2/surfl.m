function varargout = surfl(f,varargin)
%SURFL  3-D shaded surface with lighting for a chebfun2.
% 
% SURFL(...) is the same as SURF(...) except that it draws the surface
% with highlights from a light source.
%
% See also SURF, SURFC. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isempty(f.fun2) ) % check for empty chebfun2.
    h=surf([]);  % call the empty surf command. 
    if nargout == 1
        varargout = {h}; 
    end
    return
end 

ish = ishold;
pref2=chebfun2pref;
numpts = pref2.plot_numpts; [xx,yy]=cheb2pts(numpts,numpts,f.fun2.map);
vals = f.feval(xx,yy);

if ( isempty(varargin) )
    h = surfl(xx,yy,vals);
else
    h = surfl(xx,yy,vals,varargin{:});
end
shading interp
    

if ( ~ish ), hold off; end 
if ( nargout >1 ) 
    varargout = {h}; 
end

end