function m = slitp(par,plotflag)
% SLITP - Slit maps: See Hale's thesis or Hale & Tee 2009.
%  M = SLITP(PAR) returns a map structure for a periodic slit map on 
%  the interval [PAR(1),PAR(2)] with singularities at PAR(3:END).
%
%  M = SLITP(PAR,FLAG) will plot images of strips under the map.
%  This is useful for testing and understanding maps.
%
%  See also slit, mpinch

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

    global pi2pi
    pi2pi = true; % should the interval [a,b] map to itself - usually yes.
    
    a = par(1);
    b = par(2);
    w = par(3:end);

    if nargin == 2, plotflag = true; else plotflag = false; end
    
    if ~isnumeric(w) || isempty(w),
        error('FUN:slitp:arg1',...
            'First argument must be slit positions');
    end

    % interval scaling
    l = @(y) ((b-a)*y/pi+b+a)/2;
    linv = @(x) pi*(2*x-b-a)/(b-a);
    scaleder = 0.5*(b-a)/pi;
    linvw = linv(w);
    
    if length(w) == 1 % single slit
        m.for = @(z) l(slitmap_p1(linvw,z,0));
        m.der = @(z) scaleder*slitmap_p1(linv(w),z,1);
        [ignored eta] = slitmap_p1(linvw,0,0);
        y = [];
    else   % multiple slits
        % compute map paramters
        [ignored eta y] = slitmap_pm(linvw,0,[],1,0,plotflag);
        m.for = @(z) l(slitmap_pm(linvw,z,y,0,0,0));
        m.der = @(z) scaleder*slitmap_pm(linvw,z,y,0,1,0);
    end

    m.par = [a b w(:).'];
    m.name = 'slitp';
    m.extra_pars = [eta y(:).'];   
    m.inherited = false;

function [gout eta] = slitmap_p1(w,z,derflag) % single slits
global pi2pi
    d = real(w); e = imag(w);
    m = sech(e/2)^2;  

    try % sc toolbox
        L = -.5*log(m)/pi; 
        [K Kp] = ellipkkp(L);
    catch no_sc
        L = [];
        K = ellipke(m);
        Kp = ellipke(1-m);
    end

    if pi2pi,  
        s = fzero(@(z) G2(z,m,L,K,d,0)-pi,pi);
    else
        s = pi;     
    end
    eta = pi*Kp/K;

    gout = G2(z+s-pi,m,L,K,d,derflag);

    
function [fout,eta,y] = slitmap_pm(wk,z,y,paramflag,derflag,plotflag)
% conformal map from period strip to multiple period slits located at d+1ie
%(USES OLD VERSION OF UNCONSTRAINED PARAMETERS (LOGS))
global pi2pi
% options
cmax = 30;     % max number of iterations in Newton loop to find preimage of slit tips
tol = 1e-10;

if nargin < 3, y = []; end           % no paramter guess
if nargin < 4, paramflag = 1; end    % solve paramter problem
if nargin < 5, derflag = 0; end      % solve paramter problem
if nargin < 6, plotflag = 0; end     % do plotting?

d = real(wk); e = imag(wk);
[d indx] = sort(d,'descend'); e = e(indx);          % sort slits by descending real part
wk = d(:)+1i*e(:);                                  % slit tips
ns = length(wk);                                    % number of slits

if isempty(y)                                       % parameter problem
    % initial parameter guess for nonlinear parameters
    m = .9999; K = ellipkkp(-.5*log(m)/pi);         % elliptic parameter & integrals
    yk = linspace(K,-K,ns+1)'; yk = yk(2:ns);       % shifts
    % convert to unconstrained problem
    y = [log(-log(1-m)) ; log(K-yk(1)) ; log(-diff(yk))];
end

% solve system of nonlinear equations
if paramflag
    fdat = {wk(1:ns),ns,tol,cmax};                  % package data
    opts = optimset('tolfun',tol,'tolx',tol,'display','off');
    y = fsolve(@(x)pfun(x,fdat),y,opts); % nonlinear system solver
end

% recover unconstrained data
m = 1-exp(-exp(y(1)));
try % sc toolbox
    L = -.5*log(m)/pi;  
    [K Kp] = ellipkkp(L);
catch no_sc
    L = [];
    K = ellipke(m);
    Kp = ellipke(1-m);
end

yk = K+cumsum([0 ; -exp(y(2)) ; -exp(y(3:end))]);
eta = pi*Kp/K;

if pi2pi                                          % shift so that f(pi) = pi
    s = fzero(@(z) FF2(z,yk,m,L,K,0)-pi,pi);
else
    s = pi;                                       % no shift
end

sizez = size(z); z = z(:);                        % convert to column vector
fout = FF2(z+s-pi,yk,m,L,K,derflag);
fout = reshape(fout,sizez);                             % reshape to size of z 

if ~plotflag return, end

%%%%%%%%%%%%%%%%%%%%% FOR TESTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% unnecessary plotting for testing
ish = ishold;
LW = 'LineWidth'; MS = 'MarkerSize';
plot(wk,'xr',LW,3,MS,8) ; hold on
plot([wk+2*pi ; wk-2*pi],'xb',LW,3,MS,8);
xx = linspace(-pi,pi,1000);
plot(slitmap_pm(wk,xx+(1-eps)*1i*eta,y,0,0,0),'-r',LW,2)
plot(slitmap_pm(wk,xx-2*pi+(1-eps)*1i*eta,y,0,0,0),'-b',LW,2)
plot(slitmap_pm(wk,xx+2*pi+(1-eps)*1i*eta,y,0,0,0),'-b',LW,2)
N = 56; X = -pi:2*pi/N:pi-1/N;
for k = (1:9)/10
    plot(slitmap_pm(wk,3*xx+k*(1-eps)*1i*eta,y,0,0,0),'--k'); 
end
plot(slitmap_pm(wk,3*X,y,0,0),0*X,'ok','markerfacecolor','k')
if ~ish, hold off, end
axis([-3*pi,3*pi,-.5*min(e),3*max(e)])
       
    
function R = pfun(y,fdat)
global a0 ak
[wk, ns, tol, cmax] = deal(fdat{:});            % package data
% recover unconstrained data
m1 = exp(-exp(y(1))); m = 1-m1;                 % elliptic parameter
try % sc toolbox
    L = -.5*log(m)/pi;  
    [K Kp] = ellipkkp(L);
catch no_sc
    L = [];
    K = ellipke(m);
    Kp = ellipke(1-m);
end
yk = K+cumsum([0 ; -exp(y(2)) ; -exp(y(3:end))]);  % shifts within elliptic funs

d = real(wk); 
a0 = d(1)-pi;
ak = -diff([d;(d(1)-2*pi)])/pi;

% find preimages of slit ends (i.e. fp = 0)
zk = .5*[(yk(ns)+2*K+yk(1)) ; (yk(1:(ns-1))+yk(2:ns))]; % initial guess
count = 0; normfp = tol+1;
while ((count <= cmax) && (normfp>tol))
    count = count+1;
    zz = repmat(zk.',ns,1)-repmat(yk,1,ns);     % zz(i,j) = zk(j) - yk(i)
    [sn cn dn] = ellipjc(zz+1i*Kp,L);           % jacobi elliptic functions
    fp = dn.'*ak;                               % f'
    fpp = -m*(sn.*cn).'*ak;                     % f''
    zk = zk - real(fp./fpp);                    % update
    normfp = norm(fp,inf);                      % error
end

if count > cmax, warning('FUN:slitp','Newton Iteration Failed. Residual = %e',normfp); end
   
% evaluate f at the preimages zk
z = pi*(zk+(1-eps)*1i*Kp)/K;
f = FF2(z,yk,m,L,K,0);
R = imag(f-wk);                                   % residual

   
function f = G2(z,m,L,K,d,derflag)
    Nz = floor(.5*(real((z)/pi)+1)-eps);            % zz-d = xx + 2*N*pi : xx \in [-pi,pi]
    if ~isempty(L)
        [sn cn dn] = ellipjc(K*(z)/pi-2*Nz*K,L);    % elliptic function sn(xx|m)
    else
        [sn cn dn] = ellipj(K*(z)/pi-2*Nz*K,m);          % elliptic function sn(xx|m)
    end
    if ~derflag
%         f = d+2*(asin(sqrt(1-m)*sn./dn) + Nz*pi);   % H4 MAP
        f = d+(2*Nz+1)*pi+2*asin(sn);               % H4 MAP
    else
        f = 2*K*dn/pi; 
    end
        
  
function f = FF2(z,yk,m,L,K,derflag)
global a0 ak
    zr =  K*z/pi;                                     % rescale and shift
    zz = repmat(zr.',length(yk),1)-repmat(yk,1,length(zr)); % zz(i,j) = z(j) - yk(i)
    Nz = floor(.5*(real(zz)/K+1)-eps);                % zz = xx + 2*N*K : xx \in [-K,K]
    if ~isempty(L)
        [sn cn dn] = ellipjc(zz-2*Nz*K,L);            % elliptic function sn(xx|m)
    else
        [sn cn dn] = ellipj(zz-2*Nz*K,m);             % elliptic function sn(xx|m)
    end
%     mask = (abs(sn)>1 & imag(zz)==0); sn(mask) = sign(sn(mask)); % z real => |sn| leq 1  
    fk = asin(sn) + Nz*pi;                            % fk
    if ~derflag
        f = a0 + fk.'*ak;                             % f = a_0+sum_k ak*fk
    else
        f = K*(dn.'*ak)/pi;
    end
    
% function [f fp] = FF(z,yk,L1,K,Kp)
% global a0 ak
%     zr =  K*z(:)/pi;                                  % rescale and shift
%     zz = repmat(zr.',length(yk),1)-repmat(yk,1,length(zr)); % zz(i,j) = z(j) - yk(i)
%     Nz = floor(.5*(real(zz)/K+1)-10*eps);                % zz = xx + 2*N*K : xx \in [-K,K]
%     [sn cn dn] = ellipjc3(zz-2*Nz*K,L1,K,Kp);                 % elliptic function sn(xx|m)
%     mask = (abs(sn)>1 & imag(zz)==0); sn(mask) = sign(sn(mask)); % z real => |sn| leq 1  
%     fk = asin(sn) + Nz*pi;                            % fk
%     f = a0 + fk.'*ak;                                 % f = a_0+sum_k ak*fk
%     [sn cn dn] = ellipjc3(zz,L1,K,Kp);                 % elliptic function sn(xx|m)
%     fp = dn.'*ak;
        
