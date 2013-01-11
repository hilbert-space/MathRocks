function comet(varargin)
% COMET   Two-dimensional comet plot.
% 
% A comet graph is an animated graph in which a thick dot (the comet head) 
% traces the data points on the screen. Notice that unlike the standard
% Matlab comet command, the chebfun comet does not leave a trail.
%
% COMET(F) displays a comet graph of the chebfun F, COMET(F,G) displays a
% comet of the chebfun F versus the chebfun G, and COMET(F,G,H) displays a
% comet in 3D-space using the three chebfuns as coordinates.
%
% COMET(...,'SPEED',S) where S is a real number will control the speed at 
% which the comet is updated. A larger S will result in a faster plot.
%
% COMET(...,'INTERVAL',[A B]) will restrict the comet to plot in the
% interval [A B], which should be a subset of domain(F).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

ho=ishold;
if ~ho, hold on; end

if norm(varargin{1}.ends([1,end]),inf) == inf
    error('CHEBFUN:comet:restrict','comet requires a bounded interval, please use restrict')
end

s = inf;
for k = 1:numel(varargin)-1
    if strcmpi(varargin{k},'speed'), 
        s = varargin{k+1};
        varargin(k:k+1) = [];
        break
    end
end

interval = NaN;
for k = 1:numel(varargin)-1
    if strcmpi(varargin{k},'interval'), 
        interval = varargin{k+1};
        if isa(interval,'domain'), interval = interval.ends; end
        varargin(k:k+1) = [];
        break
    end
end

j = 1; f = chebfun; plotopts = {};
for k = 1:numel(varargin)
    if isa(varargin{k},'chebfun')
        f(j) = varargin{k}; j = j+1; 
    else
        plotopts = [plotopts varargin{k}];
    end
end
numchebfuns = j-1;

if isempty(plotopts)
    plotopts = {'.r','markersize',25};
end

N = 1000;
p = 1./(1+s);

if numchebfuns == 1 && isreal(f)
    [x0,x1] = domain(f);
    if ~isnan(interval)
        if interval(1) >= x0, x0 = interval(1); 
        else error('CHEBFUN:comet:int','Invalid interval definition.'); end
        if interval(2) <= x1, x1 = interval(2); 
        else error('CHEBFUN:comet:int','Invalid interval definition.'); end
    end
    x = linspace(x0,x1,N); x(end) = [];
    ydata = feval(f,x);
    hh = plot(x(1),ydata(1),plotopts{:});
    for j = 2:length(x)
         set(hh,'xdata',x(j),'ydata',ydata(j));
         drawnow, pause(p)
    end
end

if numchebfuns == 2 || ~isreal(f(1))
    if isreal(f)
        g = f(2);
        f = f(1);
    else
        g = imag(f(1));
        f = real(f(1));
    end
    [x0,x1] = domain(f); [y0,y1] = domain(g);
    hs = max(hscale(f),hscale(g));
    if (abs(x0-y0)>1e-12*hs) || (abs(x1-y1)>1e-12*hs)
        disp('f and g must be defined on the same interval')
        return
    end
    if ~isnan(interval)
        if interval(1) >= x0, x0 = interval(1); 
        else error('CHEBFUN:comet:int','Invalid interval definition.'); end
        if interval(2) <= x1, x1 = interval(2); 
        else error('CHEBFUN:comet:int','Invalid interval definition.'); end
    end
    x = linspace(x0,x1,N);
    xdata = feval(f,x);
    ydata = feval(g,x);
    hh = plot(xdata(1),ydata(1),plotopts{:});
    for j = 2:length(x)
        set(hh,'xdata',xdata(j),'ydata',ydata(j));
        drawnow, pause(p)
    end
end

if numchebfuns == 3
    g = f(2); h = f(3); f = f(1);
    [x0,x1] = domain(f); [y0,y1] = domain(g); [z0,z1] = domain(h);
    hs = max([hscale(f) hscale(g) hscale(h)]);
    if (std([x0 y0 z0])>1e-12*hs) || (std([x1 y1 z1])>1e-12*hs)
        disp('f, g and h must be defined on the same interval')
        return
    end
    if ~isnan(interval)
        if interval(1) >= x0, x0 = interval(1); 
        else error('CHEBFUN:comet:int','Invalid interval definition.'); end
        if interval(2) <= x1, x1 = interval(2); 
        else error('CHEBFUN:comet:int','Invalid interval definition.'); end
    end
    x = linspace(x0,x1,1000);
    xdata = feval(f,x);
    ydata = feval(g,x);
    zdata = feval(h,x);
    hh = plot3(xdata(1),ydata(1),zdata(1),plotopts{:});
    for j = 2:length(x)
        set(hh,'xdata',xdata(j),'ydata',ydata(j),'zdata',zdata(j));
        drawnow, pause(p)
    end
end
delete(hh);

if ho, hold on; else hold off; end
