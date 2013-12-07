function varargout = plot(f,varargin)
%PLOT surface plot of a chebfun2
%
% PLOT(F) if F is a real-valued chebfun2 then this is the surface plot and
% is the same as surf(F). If F is a complex valued then this returns a
% domain colouring plot of F. 
%
% PLOT(F) if F is a complex-valued chebfun2 then we do Wegert's phase portrait 
% plots.
%
% PLOT(F,S) Plotting with option string plots the column and row slices,
% and pivot locations used in the construction of F.
%
% When the first argument in options is a string giving details about
% linestyle, markerstyle or colour then pivot locations are plotted.
% Various line types, plot symbols and colors may be obtained with
% plot(F,S) where S i a character string made from one element from any
% or all the following 3 columns, similar as in the usual plot command:
%
%           b     blue          .     point              -     solid
%           g     green         o     circle             :     dotted
%           r     red           x     x-mark             --    dashed
%           c     cyan          +     plus               -.    dashdot
%           m     magenta       *     star             (none)  no line
%           y     yellow        s     square
%           k     black         d     diamond
%                               v     triangle (down)
%                               ^     triangle (up)
%                               <     triangle (left)
%                               >     triangle (right)
%                               p     pentagram
%                               h     hexagram
%
% For phase portraits see: E. Wegert, Visual Complex Functions: An
% introduction with Phase Portraits, Springer Basel, 2012, or for MATLAB
% code to produce many different styles of phase portraits go to: 
% http://www.visual.wegert.com
% 
% See also SURF, MESH.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 


myish = ishold;
if ( ~isempty(varargin) )
    % See if first set of option makes it a pivot plot.
    if ( length(varargin{1})<5 )
%% Column, row, pivot plot

        % Only option with <=3 letters is a colour, marker, line
        ll = regexp(varargin{1},'[-:.]+','match');
        cc = regexp(varargin{1},'[bgrcmykw]','match');  % color
        mm = regexp(varargin{1},'[.ox+*sdv^<>ph]','match');  % marker
        
        if ( ~isempty(ll) )
            if ( strcmpi(ll{1},'.') )
                % so we have . first. Don't plot a line.
                ll = {};
            elseif ( strcmpi(ll{1},'.-') )
                % so we have . first. Don't plot a line.
                ll{1} = '-';
            end
        end
        plotline = ~isempty(ll);  % plot row and col pivot lines?
        %         if isempty(ll), ll{1}= [];end
        if isempty(mm), mm{1}= '.';end
        if isempty(cc), cc{1}= 'b';end
        % Plot the crosses and pivots on domain.
        
        % Get domain.
        rect = f.corners;
        x = rect(1); y = rect(3);
        w = rect(2)-rect(1);
        ht = rect(4)-rect(3);
        LW='LineWidth';
        
        % Calculate boundary of plotting region.
        sw = rect(1) - w/4;
        se = rect(2) +  w/4;
        nw = rect(3) - ht/4;
        ne = rect(4) +  ht/4;
        
        % plot the square domain
        rectangle('Position',[x y w ht],LW,2); hold on;
        axis([sw se nw ne]); axis equal;
        
        % Plot pivots
        fun = f.fun2;
        crosses = fun.PivPos;
        defaultopts = {'MarkerSize',7};
        extraopts = {'Marker',mm{:},'LineStyle','none','Color',cc{:}};
        if( length(varargin) < 2 )
            h=plot(crosses(:,1),crosses(:,2),extraopts{:},defaultopts{:});
        else
            h=plot(crosses(:,1),crosses(:,2),extraopts{:},defaultopts{:},varargin{2:end});
        end
        if plotline
            opts = {}; 
            if ~isempty(ll)
                opts = {opts{:},'LineStyle',ll{:},'color',cc{:}};
            end
            %plot column lines:
            line([crosses(:,1) crosses(:,1)].',[nw+ht/8 ne-ht/8],opts{:});
            %plot row lines:
            line([sw+w/8 se-w/8],[crosses(:,2),crosses(:,2)].',opts{:});
        end
        hold off
    else
%% Standard surface plot 

        h=surf(f,'facecolor','interp',varargin{:});
    end
else
    if isreal(f)
        h=surf(f,'facecolor','interp');
    else
%% Phase Protrait plot 
        % The following is a slightly modified version of Wegert's code 
        % from p345 of his book.  
        rect = f.corners; nx = 500; ny = 500;
        x = linspace(rect(1),rect(2),nx); y = linspace(rect(3),rect(4),ny);
        [xx yy]=meshgrid(x,y); zz = xx+1i*yy;
        f=feval(f,xx,yy);
        h = surf(real(zz),imag(zz),0*zz,angle(-f));
        set(h,'EdgeColor','none');
        caxis([-pi pi]), colormap hsv(600)
        view(0,90), axis equal, axis off        
    end
end

%%

if ~myish, hold off, end
if nargout > 0, varargout = {h}; end


end