function  m = slit(par,plotflag)
% SLIT - Slit maps: See Tee's thesis or Hale & Tee 2009.
%  M = SLIT(PAR) returns a map structure for a slit map on the
%  interval [PAR(1),PAR(2)] with singularities at PAR(3:END).
%
%  M = SLIT(PAR,FLAG) will plot images of ellipses under the map.
%  This is useful for testing and understanding maps.
%
%  See also mpinch, slitp

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

    a = par(1);
    b = par(2);
    w = par(3:end);

    if ~isnumeric(w) || isempty(w),
        error('FUN:slit:arg1',...
            'First argument must be slit positions');
    end

    if nargin == 2, plotflag = true; else plotflag = false; end
    
    % interval scaling
    l = @(y) ((b-a)*y+b+a)/2;
    linv = @(x) (2*x-b-a)/(b-a);
    scaleder = 0.5*(b-a);
    linvw = linv(w);

    if length(w) == 1 % single slit
        m.for = @(z) l(slitmap1(linvw,z));
        m.der = @(z) scaleder*slitmap1(linvw,z,1);
        [ignored rho] = slitmap1(linvw,linv(0));   
        y = [];
    else   % multiple slits
        % compute map paramters
        [ignored rho y] = slitmapm(linvw,[-1 1],[],1,0,plotflag);
        m.for = @(z) l(slitmapm(linvw,z,y,0,0,0));
        m.der = @(z) scaleder*slitmapm(linvw,z,y,0,1,0);
    end

    m.par = [a b w(:).'];
    m.name = 'slit';
    m.extra_pars = [rho y(:).'];
    m.inherited = false;
end

% ---------------------------------------------------------

function [gout rho] = slitmap1(wk,z,ignored) % single pair of slits
    d = real(wk); e = imag(wk);
    c = sign(d)*realsqrt(0.5*((d^2+e^2+1)-realsqrt((d^2+e^2+1)^2-4*d^2)));
    s = realsqrt(1-c^2);
    m14 = (-e+realsqrt(e^2+s^2))/s;   m = m14^4;
    if exist('ellipkkp','file') 
        L = -2*log(m14)/pi;
        [K Kp] = ellipkkp(L);
        [sn cn dn] = ellipjc(2*K*asin(z)/pi,L);
    else %no_sc
        K = ellipke(m);
        Kp = ellipke(1-m);
        [sn cn dn] = ellipj(2*K*asin(z)/pi,m);
    end
    h1 = m14*sn;
    if nargin == 2   % gout = g
        gout = c/m14+((1-m14^2)/m14)*(h1-c)./(1-h1.^2);
    else             % gout = gp
        h1p = 2*K/pi*m14*(cn.*dn)./sqrt(1-z.^2);
        h1p(abs(real(z))==1) = (2*K/pi)^2*m14*(1-m);
        gout = (1-m14^2)/m14*h1p.*(1+h1.^2-2*c*h1)./(1-h1.^2).^2;
    end
    rho = exp(pi*Kp/(4*K));
end

% ---------------------------------------------------------

function [gout rho y] = slitmapm(wk,z,y,paramflag,derflag,plotflag) % Multiple slits
    % options
    cmax = 25;     % max number of iterations in Newton loop to find preimage of slit tips
    tol = 1e-10;   % tolerance
         
    if nargin < 3, y = []; paramflag = 1; end  % no paramter guess
    if nargin < 4, paramflag = 1; end   % solve paramter problem
    if nargin < 5, derflag = 0; end     % return derivative?
    if nargin < 6, plotflag = 0; end     % return derivative?
    
    d = real(wk); e = imag(wk);
    [d,index] = sort(d(:),'descend'); e = e(index); e = e(:);
    wk = d(:)+1i*e(:);                        % slit tips (in upper-half plane)
    n = length(d);

    if length(y) ~= n
        m14 = 0.5;
        theta = linspace(0,pi,n+1)';
        phi = (theta(2:n)-theta(1:n-1))./(theta(3:n+1)-theta(1:n-1));
        y = asin(2*[m14;phi]-1);
    end

    if paramflag
        fdat = {wk,n,tol,cmax};                % package data
        % fsolve
        opts = optimset('tolfun',tol,'tolx',tol,'display','off');
        y = fsolve(@(x)mapfun(x,fdat),y,opts); % nonlinear system solver
    end

    psi = (sin(y(2:n))+1)/2;
    m14 = (sin(y(1))+1)/2;
    m12 = m14^2;
    m = m14^4;

    try % sc toolbox
        L = -2*log(m14)/pi;
        [K Kp] = ellipkkp(L);
        [sn cn dn] = ellipjc(2*K*asin(z)/pi,L);
    catch no_sc
        K = ellipke(m);
        Kp = ellipke(1-m);
        [sn cn dn] = ellipj(2*K*asin(z)/pi,m);
    end
    
    h1 = m14*sn;        % h1 map

    rhs = [zeros(n-2,1);-pi*psi(n-1)];
    LHS = diag(1-psi(2:n-1),-1)-diag(ones(n-1,1),0)+diag(psi(1:n-2),1);
    theta = LHS\rhs;
    zk = exp(1i*theta);

    ak = diff(d)/pi;
    p = PHI([-m14;m14],ak,zk);
    M = (1-m14)^2/(4*m14); M = [2/(m14^2-1) .5 .5;[-1 -M 1+M;1 -1-M M]];
    lhs = -(1-m12)/(1+m12)*(M*[ak'*(theta-pi)+d(1) ; -1-p(1) ; 1-p(2)]);
    A = lhs(1); a0 = lhs(2); b0 = lhs(3);

    if ~derflag
        gout = A + (a0./(h1-1) + b0./(h1+1)) + PHI(h1,ak,zk);
    else
        [ignored, phip] = PHI(h1,ak,zk);
        h1p = (abs(z)~=1).*(2*K/pi*m14).*cn.*dn./sqrt(1+(abs(z)==1)*eps-z.^2)+(abs(z)==1).*(2*K/pi)^2*m14*(1-m);
        gout = h1p.*(-a0./(h1-1).^2-b0./(h1+1).^2 + phip);
    end

    rho = exp(pi*Kp/(4*K));
    
    if ~plotflag, return, end

    c = .999999*exp(1i*pi*linspace(0,1,10000)).';
    ell = (1-1e-14)*rho*c; ell = .5*(ell+1./ell);
    LW = 'LineWidth'; MS = 'MarkerSize';
    ish = ishold;
    plot(d,e,'xr',LW,3,MS,8) ; hold on
    plot(slitmapm(wk,ell,y,0,0,0),'-r',LW,2);
    axis([pi*[-1,1],2*[0,1]])
    for k = [1:9]/10
        ell = (1+k*(rho-1))*c; ell = .5*(ell+1./ell);  
        plot(slitmapm(wk,ell,y,0,0,0),'--k');
    end
    if ~ish, hold off, end
end


function F = mapfun(y,fdat)
    % FORMS THE SYSTEM OF NONLINEAR EQUATIONS TO SOLVE FOR THE PARAMETERS OF THE H3 MAP
    [wk, n, tol, cmax] = deal(fdat{:});                  % package data

    m14 = (sin(y(1))+1)/2;
    m12 = m14^2;        m = m14^4;
    psi = (sin(y(2:n))+1)/2;
    rhs = [zeros(n-2,1);-pi*psi(n-1)];
    LHS = diag(1-psi(2:n-1),-1)-diag(ones(n-1,1),0)+diag(psi(1:n-2),1);
    theta = LHS\rhs;                                     % constrained angles
    zk = exp(1i*theta); zkbar = conj(zk);

    d = real(wk); e = imag(wk);
    ak = diff(d)/pi;
    p = PHI([-m14;m14],ak,zk);

    M = (1-m14)^2/(4*m14); M = [2/(m14^2-1) .5 .5 ; -1 -M 1+M ; 1 -1-M M];
    lhs = -(1-m12)/(1+m12)*(M*[ak'*(theta-pi)+d(1) ; -1-p(1) ; 1-p(2)]);
    A = lhs(1); a0 = lhs(2); b0 = lhs(3);

    s = ([0;theta]+[theta;pi])/2;
    count = 0;
    ZK = repmat(zk,1,n); ZKbar = repmat(zkbar,1,n);

    z = exp(1i*s);     ZZ = repmat(z.',n-1,1);
    gp = -a0./(z-1).^2-b0./(z+1).^2 + 1i*(1./(ZZ-ZK)-1./(ZZ-ZKbar)).'*ak;
    normgp = norm(gp,inf);

    while ((count <= cmax) && (normgp>tol))
        count = count+1;

        gpp = 2i*z.*(a0./(z-1).^3+b0./(z+1).^3) +z.*((1./(ZZ-ZK).^2-1./(ZZ-ZKbar).^2).'*ak);

        sold = s;
        s = s - imag(gp)./imag(gpp);

        tk = [theta;pi];     indx1 = s > tk;
        s(indx1) = (sold(indx1)+tk(indx1))/2;
        tk = [0;theta];        indx2 = s < tk;
        s(indx2) = (sold(indx2)+tk(indx2))/2;

        z = exp(1i*s);     ZZ = repmat(z.',n-1,1);
        gp = -a0./(z-1).^2-b0./(z+1).^2 + 1i*(1./(ZZ-ZK)-1./(ZZ-ZKbar)).'*ak;
        normgp = norm(abs(gp),inf);
        ds = norm(imag(gp)./imag(gpp),inf);
    end

    if (count > cmax)
        if normgp > 1000, F = abs(wk)+exp(5*normgp); return, end
    end  

    ff = A + (a0./(z-1) + b0./(z+1)) + PHI(z,ak,zk);
    F = imag(ff-wk);
end



function [ff ffp] = PHI(zz,ak,zk)
    sz = size(zz); zz = zz(:);
    nz = length(zz); nzk = length(zk);
    ZK = repmat(zk,1,nz);
    ZKbar = repmat(conj(zk),1,nz);
    ZZ = repmat(zz.',nzk,1);
    ZZ1 = ZZ-ZK; idx1 = find(real(ZZ1)<0 & imag(ZZ1)>=0);
    WW1 = log(ZZ1); WW1(idx1) = WW1(idx1)-2i*pi;
    ZZ2 = ZZ-ZKbar; idx2 = find(real(ZZ2)<0 & imag(ZZ2)<0);
    WW2 = log(ZZ2); WW2(idx2) = WW2(idx2)+2i*pi;
    ff = 1i*((WW1-WW2).'*ak);
    ff = reshape(ff,sz);
    if nargout > 1
        ffp = 1i*(1./(ZZ-ZK)-1./(ZZ-ZKbar)).'*ak;
        ffp = reshape(ffp,sz);
    end
end