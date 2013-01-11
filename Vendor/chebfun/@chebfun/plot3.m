function varargout = plot3(varargin)
% PLOT3 Plot a chebfun in 3-D space.
%
% PLOT3(x,y,z), where x,y,z are three chebfuns, plots a curve in 3-space
% where z=f(x,y).
%
% PLOT3(X,Y,Z), where X, Y and Z are three chebfun quasimatrices, plots
% several curves obtained from the columns (or rows) of X, Y, and Z. 

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

%   This code is a modification of the code in chebfun/plot.
numpts = chebfunpref('plot_numpts');

% Plot to a given axes
[cax,varargin] = axescheck(varargin{:});
if ~isempty(cax)
    axes(cax); %#ok<MAXES>
end

% get jumpline style and jumpval markers
jlinestyle = ':'; jmarker = 'x'; forcejmarks = false;
for k = length(varargin)-1:-1:1
    if isa(varargin,'chebfun'), break, end
    if ischar(varargin{k})
        if strcmpi(varargin{k},'JumpLine');            
            jlinestyle = varargin{k+1};
            varargin(k:k+1) = [];
        elseif strcmpi(varargin{k},'JumpMarker');      
            jmarker = varargin{k+1}; 
            forcejmarks = true;
            varargin(k:k+1) = [];
        elseif strcmpi(varargin{k},'NumPts');      
            numpts = varargin{k+1}; 
            varargin(k:k+1) = [];            
        end
    end
end

linedata = {}; markdata = {}; jumpdata = {}; dummydata = {}; jvaldata = {};
while ~isempty(varargin)
    % grab the chebfuns
    if length(varargin)>1 && isa(varargin{2},'chebfun') && isa(varargin{3},'chebfun') % three chebfuns
        f = varargin{1};
        g = varargin{2};
        h = varargin{3};
        varargin(1:3) = [];
        if ~isreal(f) || ~isreal(g) || ~isreal(h)
            warning('CHEBFUN:plot:doubleimag',...
                'Imaginary parts of complex X and/or Y arguments ignored.');
            f = real(f); g = real(g); h = real(h);
        end
    else                                                % one chebfun or quasi?
        f = varargin{1};
        if numel(f) == 3
            if f(1).trans, f = f.'; end
            g = f(:,1); h = f(:,2); f = f(:,1);
            varargin(1) = [];
            varargout = plot3(f,g,h,varargin{:});
            return
        elseif numel(f) > 3
            varargin(1) = [];
            waterfall(f,'simple',varargin{:});
            return
        else
            error('CHEBFUN:plot3:argin','First three arguments must be chebfuns.')
            
        end
    end
    
    % other data
    pos = 0;
    while pos<length(varargin) && ~isa(varargin{pos+1},'chebfun')
        pos = pos+1;
    end
    if pos > 0
        s = {varargin{1:pos}};
    else
        s = [];
    end
    varargin(1:pos) = [];
    
    % get plot data
    [lines marks jumps jumpval] = plotdata(f,g,h,numpts);

    % jump stuff
    if ~isempty(jumps) && ~isempty(jumps{1})
        tmp = jumps;           jumps = {};
        for k = 1:3:length(tmp)-1
            jumps = [jumps, {tmp{k},tmp{k+1},tmp{k+2}},jlinestyle];
        end
    else
        jumps = {NaN(1,size(lines{1},2)),NaN(1,size(lines{2},2),NaN(1,size(lines{3},2)))};
    end
    if ~isempty(jumpval)
        tmp = jumpval;         jumpval = {};
        for k = 1:3:length(tmp)-1
            jumpval = [jumpval, {tmp{k},tmp{k+1},tmp{k+2}},jmarker];
        end
    else
        jumpval = {NaN(1,size(lines{1},2)),NaN(1,size(lines{2},2)),NaN(1,size(lines{3},2))};
    end

    markdata = [markdata, marks];
    linedata = [linedata, lines, s];
    jumpdata = [jumpdata, jumps];
    jvaldata = [jvaldata, jumpval];
    dummydata = [dummydata, lines{1}(1), NaN, NaN, s];
end
markdata = [markdata, s];

h = ishold;

% Do not plot jumplines
if isempty(jlinestyle) || strcmpi(jlinestyle,'none')
    jumpdata = {NaN, NaN, NaN};
end
    
% dummy plot for legends
hdummy = plot3(dummydata{:}); hold on

h1 = plot3(linedata{:},'handlevis','off');
h2 = plot3(markdata{:},'linestyle','none','handlevis','off');
h3 = plot3(jumpdata{:},'handlevis','off');
h4 = plot3(jvaldata{:},'linestyle','none','handlevis','off');

defjlcol = true;
for k = 1:length(jlinestyle)
    if ~isempty(strmatch(jlinestyle(k),'bgrcmykw'.'))
        defjlcol = false; break
    end
end
defjmcol = true;
for k = 1:length(jmarker)
    if ~isempty(strmatch(jmarker(k),'bgrcmykw'.'))
        defjmcol = false; break
    end
end
    
for k = 1:length(h1)
    h1color = get(h1(k),'color');
    h1marker = get(h1(k),'marker');
    set(h2(k),'color',h1color);
    set(h2(k),'marker',h1marker);
    if defjlcol 
        set(h3(k),'color',h1color);
    end
    if defjmcol 
        set(h4(k),'color',h1color);
    end
    if strcmp(h1marker,'none') && ~forcejmarks
        set(h4(k),'marker','none');
    end
    set(h1(k),'marker','none');
end


if ~h, hold off; end

if nargout == 1
    varargout = {[h1 h2 h3 h4 hdummy]};
end
