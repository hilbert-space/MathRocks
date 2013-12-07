function varargout = quiver(f,varargin)
%QUIVER plot of chebfun2v
%
% QUIVER(F) plots the vector velocity field of F. QUIVER automatically
% attempts to scale the arrows to fit within the grid. The arrows are
% on a uniform grid.
%
% QUIVER(F,S) automatically scales the arrows to fit within the grid
% and then stretches them by S.  Use S=0 to plot the arrows without the
% automatic scaling. The arrows are on a uniform grid.
%
% QUIVER(X,Y,F,...) is the same as QUIVER(F,...) except the arrows are on the
% grid given in X and Y.
%
% QUIVER(...,LINESPEC) uses the plot linestyle specified for
% the velocity vectors.  Any marker in LINESPEC is drawn at the base
% instead of an arrow on the tip.  Use a marker of '.' to specify
% no marker at all.  See PLOT for other possibilities.
%
% QUIVER(...,'numpts',N) plots arrows on a N by N uniform grid.
%
% H = QUIVER(...) returns a quivergroup handle.
%
% If F is a chebfun2v with three non-zero components then this calls
% QUIVER3. 
%
% See also QUIVER3. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

numpts = 10; 

if ( isempty(varargin) )
    varargin = {};
end

% Number of points to plot
j = 1; argin = {};
while ( ~isempty(varargin) )
    if strcmpi(varargin{1},'numpts')
        numpts = varargin{2};
        varargin(1:2) = [];
    else
        argin{j} = varargin{1};
        varargin(1) = [];
        j = j+1;
    end
end
varargin = argin; 


if ( isa(f, 'chebfun2v') )        % quiver(F,...)
    % check for empty chebfun2v
    if isempty(f.xcheb) && isempty(f.ycheb)
        h = plot([]);  % empty figure.
        if nargout > 0, varargout = {h}; end
        return;
    elseif ~isempty(f.zcheb)
       h = quiver3(f,varargin{:});
       if nargout > 0 
           varargout = {h}; 
       end
    end
    % Arrows at equally-spaced points in the domain.
    fx = f.xcheb;
    rect = fx.corners;
    x = linspace(rect(1), rect(2), numpts);
    y = linspace(rect(3), rect(4), numpts);
    [xx,yy] = meshgrid(x,y);
    h = quiver(xx, yy, f, varargin{:});
    
elseif ( nargin >= 3 )            % quiver(x,y,F,...)
    % First two argument contain arrow locations;
    xx = f; yy = varargin{1};
    if ( isa(varargin{2}, 'chebfun2v') )
        f = varargin{2};
        fx = f.xcheb; fy=f.ycheb;
        rect = fx.corners;
        if ~isempty(f.zcheb)
            h = quiver3(xx,yy,f,varargin{3:end});
           if nargout > 0, varargout = {h}; end
           return;
        end
    else
        error('CHEBFUN2V:QUIVER:INPUTS', 'Third argument should be a chebfun2v.');
    end
    h = quiver(xx, yy, feval(fx,xx,yy), feval(fy,xx,yy), varargin{3:end});
    axis(1.1*rect);
    
end

if ( nargout > 0 )
    varargout = {h};
end

end