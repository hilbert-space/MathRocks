function varargout = surf(f,varargin)
%SURF Plot of the surface represented by a chebfun2v.
%
% SURF(F) is the surface plot of F, where F is a chebfun2v with three
% components.
%
% SURF(F,'-') also shows the seams of the parameterisation on the surface. 
%
% SURF(F,...) allows for the same plotting options as Matlab's SURF
% command.
%
% See also CHEBFUN2/SURF.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.


ish = ishold;

if isempty(f)
    surf([]);
    return;
end

if isempty(f.zcheb)
    error('CHEBFUN2V:SURF','Chebfun2v does not represent a surface as it has only two components');
end

% short code, by making varargin non-empty
if ( isempty(varargin) )
    varargin = {};
end

% plot seams in coordinate representation.
if ( ~isempty(varargin) )
    if ( length(varargin{1})<5 )       
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
        
        
        if isempty(cc), cc{1}= 'k';end  % default to black seam. 
        
        
        % call to chebfun2/surf
        h1 = surf(f.xcheb, f.ycheb, f.zcheb, varargin{2:end}); hold on
        
        
        if ( plotline )
            LW = 'linewidth'; lw = 2; 
            f1 = f.xcheb; f2 = f.ycheb; f3 = f.zcheb;
            rect = f1.corners;
            
            x = chebpts(100,rect(1:2));
            lft = rect(3)*ones(length(x),1);
            h2 = plot3(f1(x,lft),f2(x,lft),f3(x,lft),'linestyle',ll{1},'Color',cc{1},LW,lw); hold on
        
            rght = rect(4)*ones(length(x),1);
            h3 = plot3(f1(x,rght),f2(x,rght),f3(x,rght),'linestyle',ll{1},'Color',cc{1},LW,lw);
            
            y = chebpts(100,rect(3:4));
            dwn = rect(1)*ones(length(x),1);
            h4 = plot3(f1(dwn,y),f2(dwn,y),f3(dwn,y),'linestyle',ll{1},'Color',cc{1},LW,lw);
            
            up = rect(2)*ones(length(x),1);
            h5 = plot3(f1(up,y),f2(up,y),f3(up,y),'linestyle',ll{1},'Color',cc{1},LW,lw);
        
            h = [h1 h2 h3 h4 h5];
        else 
            h = h1; 
        end
    else
        % straight call to chebfun2/surf
        h = surf(f.xcheb, f.ycheb, f.zcheb, varargin{:});
    end
else
    % straight call to chebfun2/surf
    h = surf(f.xcheb, f.ycheb, f.zcheb, varargin{:});
end

xlim([min2(f.xcheb),max2(f.xcheb)]) 
ylim([min2(f.ycheb),max2(f.ycheb)]) 
zlim([min2(f.zcheb),max2(f.zcheb)]) 


if ~ish
    hold off
end

if ( nargout > 1 )
    varargout = {h};
end

end