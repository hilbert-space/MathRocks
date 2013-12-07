function varargout = meshz(f,varargin)
%MESHZ  Combination mesh/contour plot for a chebfun2.
%
% MESHZ(...) is the same as MESH(...) except that a contour plot
% is drawn beneath the mesh.
%
% See also MESH, MESHC.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( isempty(f) )
    h = mesh([]); % call empty mesh command.
    if ( nargout == 1 )
        varargout = {h};
    end
    return
end

doWeHoldOn = ishold;
nx = max( length(f.fun2.C), numpts ); 
ny = max( length(f.fun2.R), numpts );

% Evaluate f on a cheb tensor grid.
[xx yy]=chebpts2(nx, ny, f.corners); val = f.feval(xx,yy);

%%
% Call Matlab's meshz command to do the dirty work. 
if ( isempty(varargin) )
    h1=meshz(xx, yy, val); hold on, 
    h2=meshz(xx.', yy.', val.');
else
    h1=meshz(xx, yy, val,  varargin{:}); hold on, 
    h2=meshz(xx.', yy.', val.', varargin{:});
end

%%
if ( ~doWeHoldOn )
    hold off  % hold off if we can 
end

if ( nargout == 1 )  % return handles if required 
    varargout = {h1};
    return
elseif ( nargout == 2 )
    varargout = {h1 h2};
    return
end

end