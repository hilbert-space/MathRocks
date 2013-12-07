function  m = mpinch(par,plotflag)
% MPINCH - Multiple pinch maps: See Hale's thesis.
%  M = MPINCH(PAR) returns a map structure for a slit map on the
%  interval [PAR(1),PAR(2)] with singularities at PAR(3:END).
%
%  M = MPINCH(PAR,FLAG) will plot images of ellipses under the map.
%  This is useful for testing and understanding maps.
%
%  See also slit, slitp, compress

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

a = par(1);
b = par(2);
W = par(3:end);
  
% scale to handle arbitrary intervals
scale = @(y) .5*((b-a)*y+b+a);
scaleder = .5*(b-a);
scaleinv = @(x) (2*x-(b+a))/(b-a);

if nargin == 2, plotflag = true; else plotflag = false; end

if length(W) == 1
    [G Gi Gp] = map(W);
    zk = Gi(W);
    rho = abs(zk+sqrt(zk^2-1));
    rho = max(rho,1./rho);
else
    [G Gp Gi rho] = mpinchmap(scaleinv(W),plotflag);
end
m.par = [a b W(:).'];
m.name = 'mpinch';

m.for = @(y) scale(G(y));
m.der = @(y) scaleder*Gp(y);
m.inv = @(x) Gi(scaleinv(x));
m.inherited = false;
m.extra_pars = rho;

end

function [G Gp Gi rho] = mpinchmap(wk, plotflag)
wk = unique(wk(:)); 
Np = length(wk);
[ignored indx] = sort(real(wk)); 
wk = wk(indx);

% allocate space for single maps
alphak = zeros(Np); 
ginv_wk = zeros(Np,Np);
gfor = cell(1,Np); 
ginv = cell(1,Np); 
ginvp = cell(1,Np); 

% compute single maps
for k = 1:Np
    [gfor{k} ginv{k} ginvp{k} alphak(k,1)] = map(wk(k));
    ginv_wk(:,k) = ginv{k}(wk);
end

% unconstrain parameter problem
a = ones(Np,1)/Np;
vk = cumsum(a(1:end-1));
theta = pi*[0;vk;1];
phi = (theta(2:Np)-theta(1:Np-1))./(theta(3:Np+1)-theta(1:Np-1));
yk = asin(2*phi-1);

% solve parameter problem
% fsolve
wq = warning('query','MATLAB:optimset:InvalidParamName');
warning('off','MATLAB:optimset:InvalidParamName');
options = optimset('Display','off','Algorithm','Levenberg-marquardt');
options = optimset(options, 'TolX',1e-3,'TolFun',(1e-3)*min(abs(imag(wk))));
yk = fsolve(@(yk) pfun2(yk,ginv_wk,wk),yk,options);
warning(wq);
[F rho zk a] = pfun2(yk,ginv_wk,wk);

% inverse map
Gi = @(w) Ginv(w,a,ginv);

% forward map 
G = chebfun(@(s) newt(s,a,ginv,ginvp,wk),1024);
G = simplify(G,chebfunpref('eps'));
Gp = diff(G);

% construct barycentric interpolants
X = chebpts(length(G));
G = @(x) bary(x,feval(G,X));
Gp = @(x) bary(x,feval(Gp,X));

if ~plotflag return, end

%%%%%%%%%%%%%%%%%%%%% FOR TESTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plotting
c = exp(pi*1i*linspace(0,1,1001));
ell = .5*(rho*c+1./(rho*c));
ish = ishold;
plot(G(ell),'k','linewidth',2); hold on
plot(G(X),0*X,'o-k','markerfacecolor','k','markersize',4);
for k = 1:9
    rr = k*(rho-1)/10+1; 
    ell = .5*(rr*c+1./(rr*c));
    plot(G(ell),'--k');hold on
end
plot(wk,'ok','MarkerFaceColor','r');
axis tight
ax = [get(gca,'xlim') get(gca,'ylim')];
axis(1.05*ax+[0 0 -.1*ax(4) 0]);
if ~ish, hold off, end
end

function [gfor ginv ginvp alphak] = map(wk) % single strip-to-slit maps
    d = real(wk); e = imag(wk);
    alphak = pi/(asinh((1-d)/e)+asinh((1+d)/e));
    gfor = @(s) d+e*sinh(.5*pi/alphak*(s-1)+asinh((1-d)/e));
    ginv = @(s) 2*alphak/pi*(asinh((s-d)/e)+asinh((1+d)/e))-1;
    ginvp = @(s) 2*alphak./(pi*e*sqrt(1+((s-d)/e).^2));
end

function [F rho zk a] = pfun2(yk,ginv_wk,wk) % objective function
% revert to constrained variables
Np = length(yk)+1;
psi = (sin(yk)+1)/2;
LHS = diag(1-psi(2:Np-1),-1)-diag(ones(Np-1,1),0)+diag(psi(1:Np-2),1);
rhs = [zeros(Np-2,1);-pi*psi(Np-1)];
theta = LHS\rhs;                              
vk = theta/pi; % vk = cumsum(a)
a = [vk ; 1];
for k = 2:length(a)
    a(k) = a(k) - sum(a(1:k-1));
end

% preimages of tips
zk = ginv_wk*a;

% ellipses
rk = abs(zk+sqrt(zk.^2-1));
rk = max(rk,1./rk);

[rho indx] = min(rk); rk(indx) = [];
F = rho - rk;

% scaling
pp = wk; pp(indx) = [];
ip = imag(pp); mip = min(imag(wk));
arp = abs(real(pp));
F = F./(1+(F<0).*(exp(10*((arp>1).*(arp-1)+ip-mip))-1));
end

function H = Ginv(w,a,ginv) % compute G inverse
[m n] = size(w);
w = w(:);
H = 0;
for k = 1:length(a)
    H = H + a(k)*ginv{k}(w);
end
H = reshape(H,m,n);
end

function Hp = Ginvp(w,a,ginvp) % compute G inverse prime
[m n] = size(w);
w = w(:);
Hp = 0;
for k = 1:length(a)
    Hp = Hp + a(k)*ginvp{k}(w);
end
Hp = reshape(Hp,m,n);
end

function [H Hp] = Ginv2(w,a,ginv,ginvp)  % compute G inverse and Ginv prime
[m n] = size(w);
w = w(:);
H = 0; Hp = 0;
for k = 1:length(a)
    H = H + a(k)*ginv{k}(w);
    Hp = Hp + a(k)*ginvp{k}(w);
end
H = reshape(H,m,n);
Hp = reshape(Hp,m,n);    
end

% invert the inverse via fsolve or ode45 + Newton iterations
function w = newt(s,a,ginv,ginvp,wk)  
    if length(s) == 2, w = s; return, end
    tol = chebfunpref('eps');
    try
        % fsolve
        options = optimset('Display','off','Algorithm','trust-region-reflective');
        options = optimset(options, 'TolX',tol,'TolFun',tol);
        options = optimset(options,'Jacobian','off','JacobPattern',speye(length(s)));
        w = fsolve(@(ww) Ginv(ww,a,ginv)-s,s,options);
    catch no_fsolve
        % ode45 and Newton
        tol2 = min([1e-7 ; max(abs(imag(wk)),eps)]);
        opts = odeset('abstol',tol,'reltol',tol2,'vectorized',1);
        [ignored w] = ode45(@(t,ww) 1./Ginvp(ww,a,ginvp),s,-1,opts);
        norm(Ginv(w,a,ginv)-s,inf)
        k = 0; err = inf; step = inf;
        while err > 1e-15 && norm(step,inf) > 1e-14
            k = k+1;
            [H Hp] = Ginv2(w,a,ginv,ginvp);
            step = (H-s)./Hp;
            step = min(step,.001);
            w = w-step;
            err = norm(abs(H-s),inf);
            if k > 50, break; end
        end
    end
end
