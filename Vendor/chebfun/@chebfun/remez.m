function varargout = remez(f,varargin)
% Best polynomial or rational approximation.
%
% REMEZ(F,M,N) computes the best rational approximation of type [M/N] of a
% chebfun F using the Remez algorithm.  The particular case REMEZ(F,N) 
% computes the best polynomial approximation of degree N .
%
% REMEZ(...'tol',TOL) uses the value TOL as the termination tolerance on
% the increase of the levelled error. 
%
% REMEZ(...'display','iter') displays output at each iteration.
%
% REMEZ(...'maxiter',MAXITER) uses MAXITER as the maximum number of
% iterations allowed.
%
% REMEZ(...'plotfcns','error') plots the error function while the algorithm
% executes.
%
% P = REMEZ(...) returns a chebfun P for the best polynomial approximation.
%
% [P,Q] = REMEZ(...) returns chebfuns P and Q for best rational
% approximation. [P,Q,R_HANDLE] = REMEZ(...) also returns a function handle 
% R_HANDLE to evaluate the rational function P/Q.
%
% [P,ERR] = REMEZ(...) and [P,Q,R_HANDLE,ERR] = REMEZ(...) also return the 
% maximum error ERR.    
%
% [P,ERR,STATUS] = REMEZ(...) and [P,Q,R_HANDLE,ERR,STATUS] = REMEZ(...) 
% also return the structure array STATUS with the fields DELTA, ITER, DIFFX
% and XK with the obtained tolerance, number of performed iterations, 
% maximum correction in the last trial reference and last trial reference 
% on which the error equioscillates respectively.
%
% This code is quite reliable for polynomial approximations but rather
% fragile for rational approximations.  Better results can often be
% obtained with CF, especially if f is smooth.
%
% See Pachon and Trefethen, "Barycentric-Remez algorithms for best 
% polynomial approximation in the chebfun system", BIT Numerical 
% Mathematics 49 (2009),721-741) and Pachon, "Algorithms for 
% Polynomial and Rational Approximation", D.Phil. Thesis, University of 
% Oxford, 2010 (Chapter 6).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if numel(f) > 1, error('CHEBFUN:remez:quasi',...
        'Remez does not currently support quasimatrices'); end

if numel(f) > 1, % Deal with quasimatrices    
    trans = false;
    if get(f,'trans')
        f = f.'; trans = true;
    end
    r = cell(1,numel(f)); p = chebfun; q = chebfun;
    s = zeros(1,numel(f));    
    for k = 1:numel(f)             % loop over chebfuns
      if (nargin < 4), M = length(f(:,k)) - 1; end
      [p(:,k) q(:,k) r{k} s(k)] = remez(f(:,k),varargin);
    end
    if trans
        r = r.'; p = p.'; q = q.';
    end
    return
end
if any(get(f,'exps')<0), 
    error('CHEBFUN:remez:inf',...
     'Remez does not currently support functions which diverge to infinity'); 
end
spl_ini = chebfunpref('splitting');
splitting off,
if ~mod(nargin,2) % even number of input parameters: polynomial case
    N = varargin{1};
    m = N;
    n = 0; rational = 0;
    varargin = varargin(2:end);
else % odd number of input parameters: rational case
       m = varargin{1}; n = varargin{2};
       rational = 1;
       [m,n] = detectdegeneracy(f,m,n);
       N = m+n;
       varargin = varargin(3:end);
end
% parameters
iter = 0;
maxit = 20; 
[a,b] = domain(f);
sigma = ones(N+2,1); sigma(2:2:end) = -1;  % alternating signs
normf = norm(f); 
delta = normf; deltamin = inf;
diffx = 1;
disp_iter = 0;
draw_option = 0;
tol = 1e-16*(N^2+10);   % tolerance
% read optional input arguments
for k = 1:2:length(varargin)
    if strcmpi('tol',varargin{k})
        tol = varargin{k+1};
    elseif strcmpi('display',varargin{k})
        disp_iter = 1;
    elseif strcmpi('maxiter',varargin{k})
        maxit = varargin{k+1};
    elseif strcmpi('plotfcns',varargin{k})
        draw_option = 1;
    else
        error('CHEBFUN:remez:input_parameters',...
            'Unrecognized sequence of input parameters.')
    end        
end

if n == 0, qk = 1; q = chebfun(1,[a,b]); qmin = q; end
% initial reference
flag = 0;
if n > 0 % initial reference from Chebyshev-Pade
    if f.nfuns == 1
        % [p,q] = chebpade(f,m,n);     % <- change initial guess to Chebyshev-Pade
         [p,q] = cf(f,m,n);             % <- change initial guess to CF
    else
        % [p,q] = chebpade(f,m,n,5*N); % <- change initial guess to Chebyshev-Pade
         [p,q] = cf(f,m,n,5*N);        % <- change initial guess to CF
    end
    [xk,err,e,flag] = exchange([],0,2,f,p,q,N+2);
end
if n==0 || flag == 0 
    xk = chebpts(N+2,[a,b]);
end
xo = xk;


if disp_iter
    disp(['It.     Max(|Error|)       |ErrorRef|      Delta ErrorRef      Delta Ref'])    
end

if draw_option
    xxk = linspace(a,b,300);
end

while (delta/normf > tol) && iter <maxit && diffx > 0
    %iter
    fk = feval(f,xk);                             % function values 
    w = bary_weights(xk);                         % compute barycentric weights
    % computatiom of levelled error   
    if n > 0 
        % in case of rational case, obtain simultaneously the levelled
        % error and the values of the trial denominator
       [C,ignored] = qr(fliplr(vander(xk)));            % orthogonal matrix wrt <,>_xk
       ZL=C(:,m+2:N+2).'*diag(fk)*C(:,1:n+1);     % left rational interp matrix
       ZR=C(:,m+2:N+2).'*diag(sigma)*C(:,1:n+1);  % right rational interp matrix 
       [v,d] = eig(ZL,ZR);                        % solve generalize eig problem
       qk_all = C(:,1:n+1)*v;                     % compute all possible qk 
       pos =  find(abs(sum(sign(qk_all)))==N+2);  % signs' changes of each qk
       if isempty(pos)||length(pos)>1
         error('Trial interpolant too far from optimal');
       end    
       qk = qk_all(:,pos);                        % keep qk with unchanged sign
       h = d(pos,pos);                            % levelled reference error 
    else
       % in case of polynomial case, compute directly the levelled error
       h = (w'*fk)/(w'*sigma);                    % levelled reference error  
    end    
    if h==0, h = 1e-19; end                       % perturb error if necessary         
    pk = (fk - h*sigma).*qk;                      % vals of r x q in reference
    p = chebfun(@(x) bary(x,pk,xk,w),[a,b],m+1);  % chebfun of trial numerator
    if n > 0
     q =chebfun(@(x) bary(x,qk,xk,w),[a,b],n+1);  % chebfun of trial denominator   
    end
    if draw_option,
        plot(xk,0*xk,'or','markersize',12),  hold on,        
    end    
    
    [xk,err,e] = exchange(xk,h,2,f,p,q,N+2);
    if err/normf > 1e5                            % if overshoot, recompute with one-
        [xk,err,e] = exchange(xo,h,1,f,p,q,N+2);  % point exchange
    end    
        if draw_option
          plot(xk,0*xk,'*k','markersize',12); 
          plot(xxk,e(xxk)),   
          hold off,
          xlim([a,b])
          legend('current ref','next ref','error')
          drawnow,
         end
    diffx = max(abs([xo-xk]));
    xo = xk;
    delta = err - abs(h);                         % stopping value 
    if delta < deltamin,                          % store poly with minimal norm       
      pmin = p; errmin = err; xkmin = xk;          
      if n > 0 , qmin = q; end  
      deltamin = delta;
      itermin = iter;
    end
    
    iter = iter+1; 
    if disp_iter
      disp([num2str(iter),'        ',num2str(err,'%5.4e'),'        ',...
          num2str(abs(h),'%5.4e'),'        ',...
          num2str(delta/normf,'%5.4e'),'        ',num2str(diffx,'%5.4e')]),
    end
end
itermin;
p = pmin;
err = errmin;
xk = xkmin;
delta = deltamin;
if delta/normf > tol
    warning('CHEBFUN:remez:convergence',...
        ['Remez algorithm did not converge after ',num2str(iter),...
        ' iterations to the tolerance ',num2str(tol),'.']),
end
    
%if rational , q = qmin; end
if rational , q = simplify(qmin,1e-14,'force'); end
p = simplify(p,1e-14,'force');
if ~rational 
    if nargout >= 1, varargout(1) = {p};   end
    if nargout >= 2, varargout(2) = {err}; end
    if nargout == 3, 
        status.delta = delta/normf;
        status.iter = iter;
        status.diffx = diffx;
        status.xk =  xk;
        varargout(4) = {status}; end
elseif rational
    if nargout >= 1, varargout(1) = {p};   end
    if nargout >= 2, varargout(2) = {q}; end
    if nargout >= 3, varargout(3) = {@(x) feval(p,x)./feval(q,x)};  end
    if nargout >= 4, varargout(4) = {err};  end
    if nargout == 5, 
        status.delta = delta/normf;
        status.iter = iter;
        status.diffx = diffx;   
        status.xk = xk;
        varargout(5) = {status}; end
end
chebfunpref('splitting',spl_ini), 


%-------------------------------------------------------------------------%
    function [xk,norme,e,flag] = exchange(xk, h, method, f, p, q, Npts)  
    % EXCHANGE modifies an equioscillation reference using the Remez 
    % algorithm.
    %
    % EXCHANGE(XK,H,METHOD,F,P,Q) performs one step of the Remez algorithm 
    % for the best rational approximation of the chebfun F of the target 
    % function according to the first method (METHOD = 1), i.e. exchanges 
    % only one point, or the second method (METHOD = 2), i.e. exchanges all 
    % the reference points. XK is a column vector with the reference, H is 
    % the levelled error, P is the numerator and Q is the denominator of
    % the trial rational function P/Q.
    %
    % [XK, NORME, E_HANDLE, FLAG] = EXCHANGE(...) returns the modified 
    % reference XK, the supremum norm of the error NORME (included as an 
    % output argument, since it is readily computing in EXCHANGE and is 
    % used later in REMEZ), a function handle E_HANDLE for the error, and a
    % FLAG indicating whether there were at least N+2 alternating extrema
    % of the error to form the next reference (FLAG = 1) or not (FLAG = 0).
    %
    % [XK,...] = EXCHANGE([],0,METHOD,F,P,Q,N+2) returns a grid of
    % N+2 points XK where the error F - P/Q alternates in sign (but not 
    % necessarily equioscillates). This feature of EXCHANGE is useful to 
    % start REMEZ from an initial trial function rather than an initial 
    % trial reference.    
    [a,b] = domain(f);
    e_num = (q.^2).*diff(f) - q.*diff(p) + p.*diff(q);
    rr = [a; roots(e_num); b];                   % extrema of the error
    e = @(x) feval(f,x) - feval(p,x)./feval(q,x);                  % fnc handle of error
    if method == 1                               % one-point exchange
        [tmp,pos] = max(abs(feval(e,rr))); pos = pos(1);
    else                                         % full exchange                  
        pos = find(abs(e(rr))>=abs(h));    % vals above leveled error
    end
    [r,m] = sort([rr(pos); xk]);   
    v = ones(Npts,1); v(2:2:end) = -1;
    er = [feval(e,rr(pos));v*h];
    er = er(m); 
    repeated = diff(r)==0;
    r(repeated) = []; er(repeated) = [];         % delete repeated pts
    s = r(1); es = er(1);                        % pts and vals to be kept
    for i = 2:length(r)
      if sign(er(i)) == sign(es(end)) &&...      % from adjacent pts w/ same sign 
              abs(er(i))>abs(es(end))            % keep the one w/ largest val
          s(end) = r(i); es(end) = er(i);
      elseif sign(er(i)) ~= sign(es(end))        % if sign of error changes and 
          s = [s; r(i)]; es = [es; er(i)];       % pts and vals
      end     
    end
    [norme,idx] = max(abs(es));                  % choose n+2 consecutive pts
    d = max(idx-Npts+1,1);                       % that include max of error
    if Npts<= length(s)
        xk = s(d:d+Npts-1); flag = 1;
    else
        xk = s; flag = 0;
    end
    
    % END EXCHANGE

%-------------------------------------------------------------------------%
    function [m,n] = detectdegeneracy(f,m,n)
    % DETECTDEGENERACY modifies the type of the rational approximant if
    % the function is even or odd and the defect is larger than zero.
    %
    % [M,N] = DETECTDEGENERACY(F,M,N) modifies m and n to correct the 
    % defect of the rational approximation if the target function is 
    % even or odd. In either case, the Walsh table is covered with 
    % blocks of size 2x2, e.g. for even function the best rational 
    % approximant is the same for types [m/n], [m+1/n], [m/n+1] and 
    % [m+1/n+1], with m and n even. This strategy is similar to the 
    % one proposed by van Deun and Trefethen for CF approximation in 
    % Chebfun (see chebfun/cf.m).
    %return
    [a,b] = domain(f);
    if f.nfuns>1 || length(f)>128,
      f = chebfun(f,[a,b],128);                 
    end
    c = chebpoly(f); c(end) = 2*c(end);
    if max(abs(c(end-1:-2:1)))/f.scl < eps, % f is an even function        
        if mod(m,2) ,m = m - 1; end
        if mod(n,2), n = n -1; end        
    elseif max(abs(c(end:-2:1)))/f.scl < eps, % f is an odd function
        if ~mod(m,2), m = m-1; end
        if mod(n,2), n = n - 1; end
    end
        
    % END DETECTDEGENERACY
%-------------------------------------------------------------------------%
