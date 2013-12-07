function rankdemo(f)
% RANKDEMO, watch how rank approximations converge to your chebfun2.
% 
% RANKDEMO(F), shows the convergence to F via contour plots.
% 
% Example (from SIAM News article in March 2013):  
% f = chebfun2(@(x,y) exp(-100*( x.^2 - x.*y + 2*y.^2 - 1/2).^2));
% rankdemo(f)
%
% See also CHEBFUN2/MOVIE.
 
% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

nc = 10;  % draw 10 contours on each contour plot. 
len = 40;  % plot up to rank len approximation, at most.
eyetol = 1e-3;  % eyeball tolerance. 
rect = f.corners; 
w = diff(rect(1:2)); 
h = diff(rect(3:4));
contour(f,nc), axis(rect)
if w == h, axis square; end  % make square if possible. 
set(gca,'xtick',[],'ytick',[]), % put no x or ytick on the figure. 
pause(1)

[C D R] = cdr(f); d = diag(D);  % get column, pivots, rows. 

nn = find(abs(1./d)>eyetol,1,'last');


% Reform the rank approximation, rank by rank. 
un = d(1); cn = C(:,1); rn = R(1,:);
fn = chebfun2(@(x,y) un*cn(y(:,1))*rn(x(1,:)),rect);
contour(fn,nc)
if w ==h, axis square; end 
set(gca,'xtick',[],'ytick',[])
for n = 2:min([length(d),nn,len])
  pause(.1)
  un = d(n); cn = C(:,n); rn = R(n,:);
  fn = fn + chebfun2(@(x,y) un*cn(y(:,1))*rn(x(1,:)),rect);
  contour(fn,nc),  if w==h, axis square; end
  set(gca,'xtick',[],'ytick',[]), shg
  title(sprintf('step=%2d  rank=%2d  pivot=%6.2e',n,rank(fn),1/un),'fontsize',14)
end

end