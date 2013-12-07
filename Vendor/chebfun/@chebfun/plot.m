function varargout = plot(varargin)
% PLOT   Linear chebfun plot.
%
% PLOT(F,G) plot chebfun G versus chebfun F. Quasimatrices are also
% supported in the natural way.
%
% PLOT(F) plots the chebfun F in the interval where it is defined. If F is
% a complex valued chebfun, PLOT(F) is equivalent to PLOT(real(F),imag(F)).
%
% Various line types, plot symbols and colors may be obtained with
% PLOT(F,G,S) where S i a character string made from one element from any
% or all the following 3 columns, similar as in the usual plot command
%
%          b     blue          .     point              -     solid
%          g     green         o     circle             :     dotted
%          r     red           x     x-mark             --    dashed
%          c     cyan          +     plus               -.    dashdot
%          m     magenta       *     star             (none)  no line
%          y     yellow        s     square
%          k     black         d     diamond
%                              v     triangle (down)
%                              ^     triangle (up)
%                              <     triangle (left)
%                              >     triangle (right)
%                              p     pentagram
%                              h     hexagram
%
% Markers show the chebfun value at Chebyshev points. For example,
% PLOT(F,G,'c+:') plots a cyan dotted line with a plus at each Chebyshev
% point; PLOT(F,G,'bd') plots blue diamond at each Chebyshev point but
% does not draw any line.
%
% The F,G pairs (or F,G,S triples) can be followed by parameter/value pairs
% to specify additional properties of the lines. For example,
% PLOT(F1,G1,'-',F2,G2,'--','LineWidth',2,'Color',[.6 0 0]) will plot dark
% red lines of width 2 points. 
%
% Besides the usual parameters that control the specifications of lines
% (see linespec), the parameters JumpLine and JumpMarker determine the type
% of line and style of markers respectively for discontinuities of the
% chebfun F. For example, PLOT(F,'JumpLine','-r')  will plot discontinuities
% as solid red lines, and PLOT(F,'-or','JumpMarker,'.k') will plot the
% jump values with black dots. By default the plotting styles for jumplines
% and jumpmarkers are ':' and 'x' respectively. Colours are chosen to match
% the lines they correspond to, and jump values are only plotted when the
% Chebyshev points are also plotted, unless an input 'JumpMarker','x' is
% passed. It is possible to modify other properties of jumplines and
% jumpmarkers with syntax like PLOT(F,'JumpLine',{'r','LineWidth',5}).
% Jumplines can be suppressed with the argument 'JumpLine','none'.
%
% Similarly, the parameters DeltaLine and DeltaMarker determine the 
% type of line and markers for plotting delta functions in the chebfun F.
% For example PLOT(F,'DeltaLine', '-.r', 'DeltaMarker', '*k') will
% plot dashed red lines for delta functions with black * markers.
% By default delta functions are plotted as solid lines with '^'
% as the marker. The size of the DeltaMarker is always 6 which is
% the default Matlab marker size.
%
% PLOT(F,'interval',[A B]) restricts the plot to the interval [A,B] which 
% can be useful when the domain of F is infinite, or for 'zooming in' 
% on, say, oscillatory chebfuns. PLOT(F,'numpts',N) will plot the 
% chebfun F at N equally spaced points, rather than the default 2001.
% If plotting quasimatrices or more that one F,G pair these properties
% (as with JumpLine and JumpMarker) are applied globally.
%
% PLOT(AX,...) plots into the axes with handle AX.
%
% H = PLOT(F, ...) returns a column vector of handles to line objects in
% the plot. H(:,1) contains the handles for the 'curves' (i.e. the function),
% H(:,2) contains handles for the 'marks', (i.e. the values at Chebyshev 
% points), H(:,3) for the jump lines, H(:,4) for the jump vals, H(:,5) for
% delta function lines, H(:,6)/H(:,7) for positive/negative delta function
% marker values when the marker is '^', otherwise H(:,6) contains the handles
% for all delta function markers and H(:,7) contains dummy data. 
% Finally, H(:,8) contains the handle for a dummy plot used to supply correct legends.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

numpts = chebfunpref('plot_numpts');

% Plot to a given axes
[cax,varargin] = axescheck(varargin{:});
if ~isempty(cax)
    axes(cax); %#ok<MAXES>
end

% Get jumpline style and jumpval markers
jlinestyle = ':'; jmarker = 'x'; forcejmarks = false;

% Get delta style and deltaval markers for plotting delta functions
dlinestyle = '-'; dmarker = '^'; forcedmarks = true;

infy = false; interval = [];
for k = length(varargin):-1:1
    if isa(varargin,'chebfun'), break, end
    vk = varargin{k};
    if ischar(varargin{k})
        if strcmpi(vk,'JumpLine');            
            jlinestyle = varargin{k+1};
            varargin(k:k+1) = [];
        elseif strcmpi(vk,'JumpMarker');      
            jmarker = varargin{k+1}; 
            forcejmarks = true;
            varargin(k:k+1) = [];
        elseif strcmpi(vk,'DeltaLine');
            dlinestyle = varargin{k+1};
            varargin(k:k+1) = [];
        elseif strcmpi(vk,'DeltaMarker');
            dmarker = varargin{k+1};
            forcedmarks = true;
            varargin(k:k+1) = [];
        elseif strcmpi(vk,'NumPts');      
            numpts = varargin{k+1}; 
            varargin(k:k+1) = [];
        elseif strcmpi(vk,'Interval');      
            interval = varargin{k+1}; 
            varargin(k:k+1) = [];          
        end    
    elseif isnumeric(vk) && length(vk) == 2 && length(varargin) < 3
        if diff(vk)<0
            error('CHEBFUN:plot:interval','Plotting interval must be positive.');
        end
        if ~strcmpi(varargin{k-1},'Interval')
            interval = vk;
            varargin(k) = [];
        end
    end
end

linedata = {}; markdata = {}; jumpdata = {}; jvaldata = {};
deltadata = {}; dvaldata = {}; dummydata = {}; LW = [];
bot = inf; top = -inf;
while ~isempty(varargin)
    % grab the chebfuns
    if length(varargin)>1 && isa(varargin{2},'chebfun') % two chebfuns
        f = varargin{1};
        g = varargin{2};
        varargin(1:2) = [];
        if ~isreal(f) || ~isreal(g)
            warning('CHEBFUN:plot:doubleimag',...
                'Imaginary parts of complex X and/or Y arguments ignored.');
            f = real(f); g = real(g);
        end
    elseif isa(varargin{1},'chebfun')  % one chebfun
        f = [];
        g = varargin{1};
        varargin(1) = [];
    else % no chebfuns!
        f = [];
        g = [];
    end
    
    % other data
    pos = 0;
    while pos<length(varargin) && ~isa(varargin{pos+1},'chebfun')
        pos = pos+1;
    end
    if pos > 0
        s = {varargin{1:pos}};
        idx = find(strcmp(s,'linewidth'),1);
        if any(idx), LW = {'linewidth',s{idx+1}}; else LW = []; end
    else
        s = [];
    end
    varargin(1:pos) = [];
    
    % get plot data
    if ~isempty(g)
        [lines marks jumps jumpval deltas deltaval misc] = plotdata(f,g,[],numpts,interval);
    else
        linedata = [linedata s];  markdata = [markdata s];
        jumpdata = [jumpdata s];  jvaldata = [jvaldata s];
        deltadata = [deltadata s]; dvaldata = [dvaldata s];
        continue
    end
    
    % limits for inf plots
    if length(misc) == 3
        infy = max(infy,misc(1));
        bot = min(bot,misc(2)); 
        top = max(top,misc(3));
    end
    
    % jump stuff
    if ~isempty(jumps) && ~isempty(jumps{1})
        tmp = jumps;           jumps = {};
        for k = 1:2:length(tmp)-1
            jumps = [jumps, {tmp{k},tmp{k+1}},jlinestyle];
        end
    elseif ~isempty(lines)
        jumps = {NaN(1,size(lines{1},2)),NaN(1,size(lines{2},2))};
    end
    
    if ~isempty(jumpval)
        tmp = jumpval;         jumpval = {};
        for k = 1:2:length(tmp)-1
            jumpval = [jumpval, {tmp{k},tmp{k+1}},jmarker];
        end
    elseif ~isempty(lines)
        jumpval = {NaN(1,size(lines{1},2)),NaN(1,size(lines{2},2))};
    end
    
    % delta stuff
    if ~isempty(deltas) && ~isempty(deltas{1})
        tmp = deltas;          deltas = {};
        for k = 1:2:length(tmp)-1
            deltas = [deltas, {tmp{k},tmp{k+1}},dlinestyle];       
        end
    elseif ~isempty(lines)
        deltas = {NaN(1,size(lines{1},2)),NaN(1,size(lines{2},2))};
    end
                
    
    if ~isempty(deltaval)
        tmp = deltaval;         deltaval = {};
        for k = 1:3:length(tmp)-1
            % delta marker data:     x        y       sign     marker
            deltaval = [deltaval, {tmp{k},tmp{k+1}, tmp{k+2}},dmarker];
        end
    elseif ~isempty(lines)
        deltaval = {NaN(1,size(lines{1},2)),NaN(1,size(lines{2},2))};
    end
    
    if ~isempty(lines)
        linedata = [linedata, lines,s];
    end
    if ~isempty(marks)
        markdata = [markdata, marks,s];
    end
    jumpdata = [jumpdata, jumps, LW];
    jvaldata = [jvaldata, jumpval];
    deltadata = [deltadata, deltas, LW];
    dvaldata = [dvaldata, deltaval];
    if ~isempty(lines)
        dummydata = [dummydata, lines{1}(1), NaN*ones(size(lines{2},2),1), s];
    end        
end
if isempty(markdata), 
    markdata = {[]};
else
%     markdata = [markdata, s];
end
if isempty(dummydata), dummydata = {[]}; end
if isempty(linedata), linedata = {[]}; end
if isempty(jumpdata), jumpdata = {[]}; end
if isempty(jvaldata), jvaldata = {[]}; end
if isempty(deltadata), deltadata = {[]}; end
if isempty(dvaldata), dvaldata = {[]}; end

% Are we holding the current axis?
h = ishold;

% Get current axes limits
if h && all(~isinf([bot top])) && infy
    try
        yl = get(gca,'ylim');
        bot = min(yl(1),bot);
        top = max(yl(2),top);
    catch ME %#ok<NASGU>
        % do nothing
    end
end

% Do not plot jumplines
if isempty(jlinestyle) || (ischar(jlinestyle) && strcmpi(jlinestyle,'none'))
    jumpdata = {NaN, NaN};
end
% Do not plot deltalines
if isempty(dlinestyle) || (ischar(dlinestyle) && strcmpi(dlinestyle,'none'))
    deltadata = {NaN, NaN};
end

% Do not plot delta markers
if isempty(dmarker) || (ischar(dmarker) && strcmpi(dmarker,'none'))
    forcedmarks = false;
end
% Dummy plot for legends
hdummy = plot(dummydata{:}); hold on
% Plot lines, marks, jumplines, jumpvals, deltalines and deltavals
h1 = plot(linedata{:},'handlevis','off');
h2 = plot(markdata{:},'linestyle','none','handlevis','off');
h3 = plot(jumpdata{:},'handlevis','off');
if forcejmarks
    h4 = plot(jvaldata{:},'linestyle','none','handlevis','off');
else
    h4 = NaN(size(h1));
end
h5 = plot(deltadata{:},'handlevis','off');
if forcedmarks   % default setting for delta functions
    % deal with the '^' marker for delta functions
    dvaldata = makedvaldata(dvaldata);
    % the delta marker is always of the default size 6
    h6 = plot(dvaldata{:}, 'markersize', 6, 'linestyle','none','handlevis','off');
    h7 = h6(2:2:end); % handles to negative delta markers
    h6 = h6(1:2:end); % handles to positive delta markers
else
    h6 = NaN(size(h1));
    h7 = NaN(size(h1));
end


% Colours of jumplines and jumpval markers
defjlcol = true; % use color of corresponding line?
colours = {'b','g','r','c','m','y','k','w'};
for k = 1:length(jlinestyle)
    if any(strncmp(jlinestyle(k),colours,1))
        defjlcol = false; break
    end
end
defjmcol = true; % use color of corresponding line?
for k = 1:length(jmarker)
   if any(strncmp(jmarker(k),colours,1))
       defjmcol = false; break
   end
end

% Colours of deltalines and delta markers
defdlcol = true; % use color of corresponding line?
for k = 1:length(dlinestyle)
    if any(strncmp(dlinestyle(k),colours,1))
        defdlcol = false; break
    end
end
defdmcol = true; % use color of corresponding line?
for k = 1:length(dmarker)
    if any(strncmp(dmarker(k),colours,1))
        defdmcol = false; break
    end
end

% Enforce colours
if numel(h2) == numel(h1)  % This should always be the case??
    for k = 1:length(h1)
        h1color = get(h1(k),'color');
        h1marker = get(h1(k),'marker');
        set(h2(k),'color',h1color);
        set(h2(k),'marker',h1marker);
        set(h1(k),'marker','none');
        if defjlcol && numel(h3) == numel(h1)
            set(h3(k),'color',h1color);
        end
        
        if forcejmarks && numel(h4) == numel(h1) && defjmcol
            set(h4(k),'color',h1color);
        end        
              
        if defdlcol && numel(h5) == numel(h1)
            set(h5(k),'color',h1color);
        end
          
        if forcedmarks && numel(h6) == numel(h1) && numel(h7) == numel(h1)
            if(defdmcol)
                % if no marker color is provided, use default
                set(h6(k),'color',h1color, 'MarkerFaceColor', h1color);
                set(h7(k),'color',h1color, 'MarkerFaceColor', h1color);
            else
                % fill the delta markers with the provided colour
                set(h6(k),'MarkerFaceColor',get(h6(k),'color'));
                set(h7(k),'MarkerFaceColor',get(h7(k),'color')); 
            end
        end               
    end
end

% Set the axis limits
if length(interval) == 4
    set(ax,'ylim',interval(3:4))
elseif all(~isinf([bot top])) && infy
    try
        set(gca,'ylim',[bot top])
    catch ME  %#ok<NASGU>
        % do nothing
    end
end

% Reset hold
if ~h, hold off; end

% Output handles
if nargout == 1
    % lines markers jumplines jumpvals deltalines deltavals+ deltavasl-
    % dummy
    varargout = {[h1 h2 h3 h4 h5 h6 h7 hdummy]};
end
end

function newdvaldata = makedvaldata(dvaldata)
% MAKEDVALDATA handles the case when '^' is used as delta
% marker. The number of handles for plotting delta data
% are doubled as a result of the formatting, regardless
% of the marker type.
% 
% Input  format: [xdelta] [ydelta] [sign] [marker]
% Output format: [xdelta] [positive delta] [marker],
%                [xdelta] [negative delta] [marker]

n = length(dvaldata);
if n < 4, newdvaldata = dvaldata; return; end
% check the format
if(n/4 ~= round(n/4))
    error('CHEBFUN:plot:makedvaldata','delta data does not have the expected format');
end
% set the length of newdvaldata
newdvaldata = cell(1,2*(n-n/4));
for k = 1:4:n
    % index mapping from 4-block to 6-block
    kk = (3*k-1)/2;
    if(dvaldata{k+3}=='^')
        x1 = dvaldata{k};
        y1 = dvaldata{k+1};
        sgn = dvaldata{k+2};
        % keep the positive deltas and nan's in one cell
        idx =(sgn>=0|isnan(y1));
        newdvaldata{kk}=x1(idx);
        newdvaldata{kk+1}=y1(idx);
        newdvaldata{kk+2}= '^';
        % if there are no neagtive deltas
        if(all(idx))
            % add dummy data
            newdvaldata(kk+3:kk+4)={NaN NaN};
            newdvaldata{kk+5} = '';
        else
            % copy negative deltas with 'v' marker
            newdvaldata{kk+3}=x1(~idx);
            newdvaldata{kk+4}=y1(~idx);
            newdvaldata{kk+5}='v';
        end
    else
        % keep the original marker and data
        newdvaldata(kk:kk+2) = {dvaldata{k:k+1}, dvaldata{k+3}};
        % attach NaNs and a dummy marker
        newdvaldata(kk+3:kk+4) = {NaN NaN};
        newdvaldata{kk+5} = '';
    end  
end
end % newdeltaval()