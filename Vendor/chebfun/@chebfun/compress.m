function fout = compress(fin,fin2,failflag,plotflag,paramoutflag)
% COMPRESS   
% 
% Attempt to compress the length of a chebfun using pinch maps.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

eps = 1e-14;
[a b] = domain(fin);
scale = @(y) .5*((b-a)*y+b+a);

% split the interval
if nargin > 1,
    ff = chebfun(@(x) feval(fin2,x),[a,b],'map',{'linear'},'splitdegree',56,'eps',eps,'splitting','on');
else
    ff = chebfun(@(x) feval(fin,x),[a,b],'map',{'linear'},'splitdegree',56,'eps',eps,'splitting','on');
end
if ff.nfuns == 1
    fout = fin; return
end

if nargin < 3, failflag = 1; end
if nargin < 4, plotflag = 0; end
if nargin < 5, paramoutflag = 0; end

% find intersections -----------------------------
ends = (2*ff.ends-(b+a))/(b-a);
rho = []; e = [];
l = ends(1:end-1); r = ends(2:end);
for k = 1:ff.nfuns
    N = length(ff.funs(k));
    if N > 1
        rho(k) = .9*(eps^(-1/N)-1)+1;            
    else
        rho(k) = 1;
    end
end

alpha = 1/16*((rho-1./rho)./(rho+1./rho)).^2;
beta = ((r-l).*(rho+1./rho)).^2;
gamma = .5*(r+l);

A = 16*diff(alpha);
B = -16*diff(alpha.*gamma);
C = -diff(alpha.*(beta-16*gamma.^2));

if B.^2<A.*C, disp('No intersection'); return, end
x = (-B-sqrt(B.^2-A.*C))./A;
mask = find(A == 0); x(mask) = -.5*C(mask)./B(mask);

% % evaluate y
y = sqrt(alpha(1:end-1).*(beta(1:end-1)-16*(x-gamma(1:end-1)).^2));

% include tops of ellipses
% x = [x gamma]; y = [y sqrt(alpha.*beta)];

% replace jumk with tops of ellipses
mask = unique([find(isnan(x)) find(logical(imag(y))) find(y==0) find(abs(x)>1.2)]);
if ~isempty(mask)
    for k = mask
        if k == length(x)
            x(k) = gamma(end); y(k) = sqrt(alpha(end).*beta(end));
        end
        [y(k) indx] = min(sqrt(alpha(k:k+1).*beta(k:k+1)));
        x(k) = gamma(k-1+indx);
    end
end

if plotflag
xx = linspace(-sqrt(beta(1))/4+gamma(1),x(1),10000);
yy = sqrt(alpha(1).*(beta(1)-16*(xx-gamma(1)).^2));
for k = 1:length(x)-1
    xxk = linspace(x(k),x(k+1),10000);
    xx = [xx ; xxk];
    yy = [yy ; sqrt(alpha(k+1).*(beta(k+1)-16*(xxk-gamma(k+1)).^2))];
end
xxk = linspace(x(end),sqrt(beta(end))/4+gamma(end),10000);
xx = [xx ; xxk];
yy = [yy ; sqrt(alpha(end).*(beta(end)-16*(xxk-gamma(end)).^2))];
zz = [xx+1i*yy].';
plot(scale(zz),'--'); hold on
plot(scale(x+1i*y),'or')
end

[x indx] = sort(x); y = y(indx); 
% add ends of first and last ellipses
% x = [-sqrt(beta(1))/4+gamma(1) x sqrt(beta(end))/4+gamma(end)];
% y = [sqrt(alpha(1).*beta(1))/100 y sqrt(alpha(end).*beta(end))/100];
% (end of) find intersections -----------------------------

% map parameters
p = x+.8*1i*y;
p(p==0) = [];
if paramoutflag, fout = p; return, end

if length(p) < 2,
    % use single slit map
    fout = chebfun(@(x) feval(ff,x), [a,b], 'map', {'slit',scale(p)});
    return
end

% mapped fun using pinch map
fout = chebfun(@(x) feval(ff,x), [a,b], 'map', {'mpinch',scale(p)});


% if length fout > length fin then compress has failed
if length(fin.ends) == 2 && length(fout) > length(fin) && failflag
    fout = fin;
end




% % old 
% function uout = compress(uin)
% % Attempt to compress a chebfun using slitmaps.
% % This was put here by NicH and is just for RodP to play with.
% 
% uout = uin;
% for k = 1:uin.nfuns
%     uout.funs(k) = compress(uin.funs(k));
% end