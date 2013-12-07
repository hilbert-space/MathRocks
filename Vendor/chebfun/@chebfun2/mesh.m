function varargout = mesh(f,varargin)
%MESH   3-D mesh surface of a chebfun2.
%
% MESH(F,C) plots the colored parametric mesh of a chebfun2.
% 
% MESH(F) uses C = height of F, so colour is proportional to mesh height.
% 
% See also MESH, MESHC, MESHZ.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isempty(f) )
    h = mesh([]); % call empty mesh command.
    if ( nargout == 1 )
        varargout = {h}; % pass a handle if appropriate.
    end
    return
end

doWeHoldOn = ishold;  numpts = 200;
nx = max( length(f.fun2.C), numpts );
ny = max( length(f.fun2.R), numpts );
rect = f.corners;

% Evaluate f on a cheb tensor grid.
[xx yy]=chebpts2(nx,ny,rect); val = f.feval(xx,yy);

%%
% Call Matlab's mesh command to do the dirty work. 
if ( isempty(varargin) )
    h1=mesh(xx,yy,val); hold on,
    h2=mesh(xx.',yy.',val.');
else
    h1=mesh(xx,yy,val,varargin{:}); hold on,
    h2=mesh(xx.',yy.',val.',varargin{:});
end

%%
if ( ~doWeHoldOn )
    hold off % hold off if we can. 
end

if ( nargout == 1 )  % return handles if required 
    varargout = {h1};
    return
elseif ( nargout == 2 )
    varargout = {h1 h2};
    return
end

end