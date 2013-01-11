function cheblogo
% Chebfun logo.

%  Copyright 2011 by The University of Oxford and The Chebfun Developers. 
%  See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

figure
f = chebpoly(10);
plot(f,'interval',[-1,.957],'linew',5), hold on

t = - cos(pi*(2:8)'/10) *0.99;  % cheb extrema (tweaked)
y = 0*t; 
h = text( t, y, num2cell(transpose('chebfun')), ...
  'fontsize',28,'hor','cen','vert','mid') ; 

flist = listfonts;
k = strmatch('Rockwell',flist);  % 1st choice
k = [k; strmatch('Luxi Serif',flist)];  % 2nd choice
k = [k; strmatch('Times',flist)];  % 3rd choice
if ~isempty(k), set(h,'fontname',flist{k(1)}), end

axis([-1.02 .98 -2 2]), axis off
set(gca,'pos',[0 0 1 1])
un = get(0,'unit'); set(0,'unit','cent')
ssize = get(0,'screensize');  set(0,'unit',un)
set(gcf,'papertype','A4','paperunit','cent','paperpos',[4.49 12.83 12 4])
pos = [ (ssize(3)-12)/2 (ssize(4)-4)/2 12 4];
set(gcf,'unit','cent','pos',pos,...
  'menuBar','none','name','Chebfun logo','numbertitle','off')

shg
comet(f,'interval',[-1,.957])

end