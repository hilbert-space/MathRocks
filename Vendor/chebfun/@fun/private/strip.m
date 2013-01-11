function map = strip(pars,plotflag)
%STRIP sausage map - See Hale's Thesis, or Hale & Trefethen
%  M = STRIP(D) creates a strip map about the interval [pars(1), pars(2)] that 
%   maps Chebyshev points into more evenly spaced ones. If pars(3) > 1,
%   then it is assumed to be the parameter rho so that the ellipse E_\rho
%   is mapped to a strip. If pars(3) <= 1, then it is taken to be the
%   parameter alpha - the height of the strip that is mapped to.
%
%  M = STRIP(PAR,FLAG) will plot images of ellipses under the map.
%   This is useful for testing and understanding maps.
%
%  See also smap, kte

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

a = pars(1); b = pars(2);
if length(pars) > 2 
    rho = pars(3);
else
    rho = 1.4; % for Historical reasons ...
end

scale = @(y) ((b-a)*y+b+a)/2;
rescale = @(x) (2*x-b-a)/(b-a);
scaleder = (b-a)/2;

if rho > 1
    num = 0; den = 0;
    for k = 1:round(.5+sqrt(10/log(rho)))
      num = num + (-1)^k*rho^(-4*k^2);
      den = den + rho^(-4*k^2);
    end
    m14 = (1+2*num)/(1+2*den);
    m1 = m14^4; 
    m4 = (1-m1)^(1/4);
    alpha = pi/(4*atanh(m4));
else
    tmp = abs(rho);
    alpha = imag(rescale(1i*abs(rho)));
    S2 = sech(pi/(4*alpha))^2;  S4 = S2^2; 
    m1 = 2*S2-S2.^2;                      
    m4 = tanh(pi/(4*alpha));   
    try % sc toolbox
        L = -2*log(m4)/pi;
        [K Kp] = ellipkkp(L);
    catch no_sc
        K = ellipke(1-m1);
        Kp = ellipke(m1);
    end
    rho = exp(pi*Kp/(4*K));
    alpha = tmp;
end

if m1 > 1e-5
    if all([a b]==[-1 1])
        map.for = @(y) stripmap1(y,m4,0);
        map.der = @(y) stripmap1(rescale(y),m4,1);
    else
        map.for = @(y) scale(stripmap1(rescale(y),m4,0));
        map.der = @(y) stripmap1(rescale(y),m4,1);
    end
else
    if all([a b]==[-1 1])
        map.for = @(y) stripmap2(y,rho,0);
        map.der = @(y) stripmap2(y,rho,1);
    else  
        map.for = @(y) scale(stripmap2(rescale(y),rho,0));
        map.der = @(y) stripmap2(rescale(y),rho,1);
    end
    alpha = imag(map.for(.5i*(rho-1/rho)));
end
    
map.name = 'strip';
map.par = [pars(1) pars(2) rho];
map.extra_pars = [alpha m1];

if nargin == 2
    c = exp(2*pi*1i*linspace(0,1,1000));
    e = .5*(rho*c+1./(rho*c)); 
    ish = ishold;
    plot(map.for(scale(e)),'-','Linewidth',2); hold on
    for k = 1:9
        r = k*(rho-1)/10+1;
        e = .5*(r*c+1./(r*c)); 
        plot(map.for(scale(e)),'--k'); 
    end
    x = chebpts(16);
    plot(map.for(scale(x)),0*x,'ok','markerfacecolor','k')
    if ~ish, hold off, end
    alpha
    axis([1.5*[a b] 1.1*alpha*[-1,1]])
end
    


function gout = stripmap1(s,m4,derflag)
masks = (s==1 | s==-1);  w = s(~masks);

m = m4^4;
try % sc toolbox
    L = -2*log(m4)/pi;
    [K Kp] = ellipkkp(L); 
    [sn cn dn] = ellipjc(2*K/pi*asin(w),L);
catch no_sc
    K = ellipke(m);
    Kp = ellipke(1-m);
    [sn cn dn] = ellipj(2*K*asin(w)/pi,m);
end

athm4 = atanh(m4);
alpha = pi/(4*athm4);
phi = 1-m4^2;

if ~derflag
    gout = 4*alpha/pi*atanh(m4*sn); 
    gout(~masks) = gout;
    gout(masks) = s(masks);
else
    % find gp
    duds = 1./sqrt(1-w.^2);
    dvdu = (2*K/pi)*cn.*dn;
    dgdv = m4./(phi*sn.^2+cn.^2)/athm4;
    gout(~masks) = dgdv.*dvdu.*duds;
    gout(masks) = (2*K/pi)^2*m4*(1+m4^2)/athm4;
end

% reshape (for matrix input)
gout = reshape(gout,size(s));


function gout = stripmap2(s,rho,derflag)
t = pi/log(rho);         d = .5+1/(exp(t*pi)+1);   p2 = pi/2;
C = 1/(log(1+exp(-t*pi))-log(2)+p2*t*d);
masks = (s==1 | s==-1);  invmasks = ~masks;        w = s(invmasks);
u = asin(w);             up = u+p2;                um = p2-u;

if ~derflag
    gout(invmasks)= C*(log(1+exp(-t*up))-log(1+exp(-t*um))+u*t*d);
    gout(masks) = s(masks);
else
    gout(invmasks) = -t*C*(1./(exp(t*up)+1)+1./(exp(t*um)+1)-d)./sqrt(1-w.^2);
    gout(masks) = C*(t*tanh(p2*t)/2)^2;
end

gout = reshape(gout,size(s));





