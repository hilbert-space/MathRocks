function varargout = quiver3(F,varargin)
%QUIVER3 3-D quiver plot of a chebfun2v.
%
% QUIVER3(F) plots velocity vectors as arrows with components
% F(1), F(2), F(3), which are chebfun2 objects. QUIVER3 automatically
% scales the arrows to fit. The arrows are plotted on a uniform grid.
%
% QUIVER3(Z,F) plots velocity vectors at the equally spaced surface points
% specified by the matrix or chebfun2 Z. If Z is a chebfun2 then we use Z
% to map the uniform grid.
%
% QUIVER3(X,Y,Z,F) plots velocity vectors at (x,y,z). If X, Y, Z are
% chebfun2 objects then we use X, Y, Z to map the uniform grid.
%
% QUIVER3(F,S), QUIVER3(Z,F,S) or QUIVER3(X,Y,Z,F,S) automatically scales
% the arrows to fit and then stretches them by S. Use S=0 to plot the
% arrows with the automatic scaling.
%
% QUIVER3(...,LINESPEC) uses the plot linestyle specified for
% the velocity vectors.  Any marker in LINESPEC is drawn at the base
% instead of an arrow on the tip.  Use a marker of '.' to specify
% no marker at all.  See PLOT for other possibilities.
%
% QUIVER(...,'numpts',N) plots arrows on a N by N uniform grid.
%
% QUIVER3(...,'filled') fills any markers specified.
%
% H = QUIVER3(...) returns a quiver object.
%
% If F is a chebfun2v with two components then we recommend using 
% CHEBFUN2V/QUIVER.
%
% See also QUIVER.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

numpts = 20; 

if isempty(varargin)
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

if isa(F,'chebfun2v') &&...
        (isempty(varargin) || ~isa(varargin{1},'chebfun2v')) % quiver3(F,...)
    rect = F.xcheb.corners;
    x = linspace(rect(1),rect(2),numpts);
    y = linspace(rect(3),rect(4),numpts);
    [xx yy] = meshgrid(x,y);
    zz = zeros(size(xx));
    vals1 = feval(F.xcheb,xx,yy);
    vals2 = feval(F.ycheb,xx,yy);
    vals3 = feval(F.zcheb,xx,yy);
    if isempty(vals3)
        vals3 = zeros(size(xx));
    end
    h = quiver3(xx,yy,zz,vals1,vals2,vals3,varargin{:});
elseif isa(F,'chebfun2') && isa(varargin{1},'chebfun2v')  %quiver(Z,F,...)
    % check that domains of Z and F are the same.
    Z = F; F = varargin{1};
    rect = Z.corners; rectcheck = F.xcheb.corners;
    if ( any(rect - rectcheck) )
        error('CHEBFUN2V:QUIVER3','Object are not on the same domain.');
    end
    zz = new_data_locations(Z,numpts);
    h = quiver3(zz,F,varargin{2:end});
elseif isa(F,'double') && isa(varargin{1},'chebfun2v')  %quiver(zz,F,...)
    zz = F; F = varargin{1};
    rect = F.xcheb.corners;
    x = linspace(rect(1),rect(2),numpts);
    y = linspace(rect(3),rect(4),numpts);
    [xx yy] = meshgrid(x,y);
    vals1 = feval(F.xcheb,xx,yy);
    vals2 = feval(F.ycheb,xx,yy);
    vals3 = feval(F.zcheb,xx,yy);
    if isempty(vals3)
        vals3 = zeros(size(xx));
    end
    h = quiver3(zz,vals1,vals2,vals3,varargin{2:end});
elseif nargin > 3        %quiver(xx,yy,zz,F,...) or quiver(X,Y,Z,F,...)
    if isa(F,'double')   % quiver(xx,yy,zz,F,...)
        xx = F; yy = varargin{1}; zz=varargin{2}; F = varargin{3};
        if ( ~isa(yy,'double') || ~isa(zz,'double') || ~isa(F,'chebfun2v') )
            error('CHEBFUN2V:QUIVER3:INPUTS','Unrecognised input arguments.');
        end
        rect = F.xcheb.corners; 
        myx = linspace(rect(1),rect(2),size(xx,1));
        myy = linspace(rect(3),rect(4),size(yy,2)); 
        [mxx myy]=meshgrid(myx,myy); 
        vals1 = feval(F.xcheb,mxx,myy);
        vals2 = feval(F.ycheb,mxx,myy);
        vals3 = feval(F.zcheb,mxx,myy);
        if isempty(vals3)
            vals3 = zeros(size(xx));
        end
        h = quiver3(xx,yy,zz,vals1,vals2,vals3,varargin{4:end});
    elseif isa(F,'chebfun2') % quiver(X,Y,Z,F,...)
        X = F; Y = varargin{1}; Z = varargin{2}; F = varargin{3};
        if ( ~isa(Y,'chebfun2') || ~isa(Z,'chebfun2') || ~isa(F,'chebfun2v') )
            error('CHEBFUN2V:QUIVER3:INPUTS','Unrecognised input arguments.');
        end
        % check everything is on the same domain.
        rectX = X.corners;  rectY = Y.corners; rectZ = Z.corners;
        rectF = F.corners;
        if ( any(rectX - rectY) || any(rectX - rectZ) || any(rectX - rectF))
            error('CHEBFUN2V:QUIVER3','Object are not on the same domain.');
        end
        
        % get new data locations.
        xx = new_data_locations(X,numpts);
        yy = new_data_locations(Y,numpts);
        zz = new_data_locations(Z,numpts);
        
        % Plot quiver3.
        h = quiver3(xx,yy,zz,F,varargin{4:end});
    end
else
    error('CHEBFUN2V:QUIVER3:INPUTS','Unrecognised input arguments.');
end

if nargout > 0
    varargout = {h};
end
end

function newloc = new_data_locations(f1,numpts)
% Generate new arrow location if first two inputs are chebfun2 objects.

% check the chebfun2 objects are on the same domain.
rect = f1.corners;

% mesh 'em up for the quiver arrows.
x = linspace(rect(1),rect(2),numpts);
y = linspace(rect(3),rect(4),numpts);

[xx,yy] = meshgrid(x,y);
newloc = feval(f1,xx,yy);      % use chebfun2 to generate data locations.

end