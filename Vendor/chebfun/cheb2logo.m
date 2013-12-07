function varargout = cheb2logo
% CHEB2LOGO The unofficial Chebfun2 logo. 
% 
% H = CHEB2LOGO; returns a figure handle to the logo. 
% 
% This is logo is only a small modification away from the Chebfun and
% Beyond workshop logo in September 2012. 
%
% See also CHEBLOGO.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

figure
f = chebpoly(10);
plot(f,'interval',[-1,.957],'linew',5), hold on

t = - cos(pi*(2:8)'/10) *0.99;  % cheb extrema (tweaked)
y = 0*t; 
h = text( t, y, num2cell(transpose('chebfun')), ...
  'fontsize',28,'hor','cen','vert','mid') ; 


axis([-1.02 1.2 -1.5 3])%, axis off
x = chebfun('x');
plot(x+.2,f+2,'interval',[-1,.957],'linew',5), hold on

ab = [-1,.957];
f1 = f{ab(1),ab(2)};
x1 = x{ab(1),ab(2)};
f2 = f1+2;
x2 = x1+.2;

xx = linspace(ab(1),ab(2),1000).';
ff = [f1(xx) f2(xx)];
close all, surf(repmat([0 1],length(xx),1),-[xx xx],ff)%, axis off
shading interp
colormap winter

fs = 18;
% fs = 24;

h1 = text( y, -t, num2cell(transpose('chebfun')), ...
  'fontsize',fs,'hor','cen','vert','mid') ; 
set(gca,'view',[ -74.500000000000000 -32.000000000000000]);
t = linspace(t(1),t(end), length(t));
h2 = text( .5*(t+1)-.05, -y-.98, (t+1)-.23,num2cell(transpose('')), ...
  'fontsize',fs,'hor','cen','vert','mid','Rotation',10) ; 
t = t(2:4);
h3 = text( .5*(t+1)-.02, -y(1:3)-1, (t+1)+.028,num2cell(transpose('two')), ...
  'fontsize',fs,'hor','cen','vert','mid','Rotation',10) ; 

% set(gca,'view',[-70.500000000000000 -14.000000000000000]);
% set(gca,'view',[-70.5000  -18.0000]);
set(gca,'view',[  -72.5000  -20.0000]);
axis off,set(gcf,'color','w')
% xlabel('x'); ylabel('y')
set(gca,'pos',[0 0 1 1])

hold on,
C = [0.2 0.2 1];
C = [0 0 1];
lw = 3;
plot3(0*xx,-xx,f1(xx),'linewidth',lw,'color',C)
plot3(0*xx+1,-xx,f2(xx),'b','linewidth',lw,'color',C)
plot3([0 1],-ab(2)*[1 1],f1(xx(end))+[0 2],'b','linewidth',lw,'color',C)
plot3([0 1],[1 1],[1 3],'b','linewidth',lw,'color',C)
% colormap bone
colormap([1 1 1;.5 .5 .5;]);

flist = listfonts;
k = strmatch('Rockwell',flist);  % 1st choice
if ~isempty(k), set(h1,'fontname',flist{k(1)})
    set(h2,'fontname',flist{k(1)})
    set(h3,'fontname',flist{k(1)})
end
set(gca,'xlim',[-.1 1])
set(gcf,'position',[440   480   560   240]);

% keyboard

oldscreenunits = get(gcf,'Units');
oldpaperunits = get(gcf,'PaperUnits');
oldpaperpos = get(gcf,'PaperPosition');
set(gcf,'Units','pixels');
scrpos = get(gcf,'Position');
newpos = scrpos/100;
set(gcf,'PaperUnits','inches',...
'PaperPosition',newpos)
print -dpng andbeyond_white
drawnow
set(gcf,'Units',oldscreenunits,...
'PaperUnits',oldpaperunits,...
'PaperPosition',oldpaperpos)

% colormap editor -1, 2
if nargout == 1 
    varargout={h}; 
end

end