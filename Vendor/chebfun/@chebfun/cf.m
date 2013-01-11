function [p,q,r,s] = cf(f,m,n,M)
% CF    Caratheodory-Fejer approximation
%
% [P,Q,R_HANDLE] = CF(F,M,N): type (M,N) rational CF approximant to chebfun F
%         defined in [a b] (which must consist of just a single fun);
%         P and Q are chebfuns representing the numerator and denominator
%         polynomials, R_HANDLE is an anonymous function that evaluates P/Q.
%
% [P,Q,R_HANDLE,S] = CF(F,M,N): same plus S, the associated CF
%         singular value, an approximation to the minimax error
%
% ... = CF(F,M,N,K): use only K-th partial sum in Chebyshev expansion of F
%
% For polynomial CF approximation, use N = 0 or N = [] or only provide two
% input arguments. If P and S are required, four output arguments must be
% specified.
%
% If F is a quasimatrix then so are the outputs P and Q, R_HANDLE is a cell
% array of function handles and s is a vector.
%
% Rational CF approximation can be very ill-conditioned for non-smooth
% functions. If the program detects this, a warning message is given and
% the results may be wrong.
%
% Example:
%   f = chebfun('log(1.2+cos(exp(2*x)))');
%   [p,q] = cf(f,10,10);
%   plot(f-p./q)
%
% CF = Caratheodory-Fejer approximation is a near-best approximation that
% is often indistinguishable from the true best approximation (which for
% polynomials can be computed using REMEZ(F,M)), but often much faster to
% compute. See M. H. Gutknecht and L. N. Trefethen, "Real polynomial
% Chebyshev approximation by the Caratheodory-Fejer method", SIAM J. Numer.
% Anal. 19 (1982), 358-371, and L. N. Trefethen and M. H. Gutknecht, "The
% Caratheodory-Fejer method for real rational approximation", SIAM J.
% Numer. Anal. 20 (1983), 420-436.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if (nargin < 3), n = 0; end

if numel(f) > 1, % Deal with quasimatrices    
    trans = false;
    if get(f,'trans')
        f = f.';        trans = true;
    end

    r = cell(1,numel(f)); p = chebfun; q = chebfun;
    s = zeros(1,numel(f));
    % loop over chebfuns
    for k = 1:numel(f)
      if (nargin < 4), M = length(f(:,k)) - 1; end
      [p(:,k) q(:,k) r{k} s(k)] = cf(f(:,k),m,n,M);
    end
    if trans
        r = r.'; p = p.'; q = q.';
    end
    return
end

if (f.nfuns > 1) && (nargin<4), error('CHEBFUN:cf:multiple_funs',...
  'For a function with multiple funs, CF must be called with 4 arguments.'); end

if (f.nfuns > 1), f = chebfun(@(x) feval(f,x),f.ends([1 end]),M+1); end

if any(get(f,'exps')), error('CHEBFUN:cf:inf',...
  'CF does not support functions with nonzero exponents.'); end

if (nargin < 4), M = length(f) - 1; end

tolfft = 1e-14; maxnfft = 2^17; % relative tolerance and max length fft
tolcond = 1e13; tolcondG = 1e3; % tolerances to detect ill-conditioning

d = domain(f);
if any(isinf(d.ends)), error('CHEBFUN:cf:inf_domain',...
  'CF does not work on infinite domains.'); end

if m >= M,
  p = f; q = chebfun(1,d); r = @(x) feval(p,x); s = 0;
  return
end

a = chebpoly(f); a = a(end-M:end);
if any(imag(a) ~= 0),
  warning('CHEBFUN:cf:complex', ...
    ['CF does not work for complex valued functions. Taking real part.']);
  a = real(a);
end

if (n == 0) | isempty(n),         % polynomial case
  if m==M-1
    p = chebfun(chebpolyval(a(2:M+1)),d); q = chebfun(1,d);
    r = @(x) feval(p,x); s = abs(a(1));
    return
  end
  c = a(M-m:-1:1);
  if length(c) > 1024,
    opts.disp = 0; opts.issym = 1; opts.isreal = 1;
    opts.v0 = ones(length(c),1)/length(c);
    [V,D] = eigs(hankel(c),1,'lm',opts);
  else
    [V,D] = eig(hankel(c));
  end
  [s,i] = max(abs(diag(D)));
  u = V(:,i);
  u1 = u(1); uu = u(2:M-m);
  b = c;
  for k = m:-1:-m
    b = [-(b(1:M-m-1)*uu)/u1 b];
  end
  pk = a(M-m+1:M+1) - [b(1:m) 0] - b(2*m+1:-1:m+1);
  p = chebfun(chebpolyval(pk),d);
  q = chebfun(1,d); r = @(x) feval(p,x);
else                              % rational case
  a(end) = 2*a(end);
  % test for even or odd functions
  if max(abs(a(end-1:-2:1)))/f.scl < eps, % f is an even function
    if ~(mod(m,2)||mod(n,2)),
      m = m + 1;
    elseif mod(m,2) && mod(n,2),
      n = n - 1;
      if (n == 0), [p,q,r,s] = cf(f,m,n,M); return; end
    end
  elseif max(abs(a(end:-2:1)))/f.scl < eps, % f is an odd function
    if mod(m,2) && ~mod(n,2),
      m = m + 1;
    elseif ~mod(m,2) && mod(n,2),
      n = n - 1;
      if (n == 0), [p,q,r,s] = cf(f,m,n,M); return; end
    end
  end
  
  % obtain eigenvalues and block structure
  [s,u,k,l,rflag] = getblock(a,m,n,M);
  if (k>0) | (l>0),
    if rflag, % f is rational function (at least up to machine precision)
      [p,q,r] = chebpade(f,m-k,n-k);
      s = eps;
      %warning('chebfun:cf:chebpade', ...
      %  'Functions looks close to rational, switching to CHEBPADE');
      return;
    end
    nnew = n - k;
    [s,u,knew,lnew] = getblock(a,m+l,nnew,M);
    if (knew>0) | (lnew>0),
      n = n + l;
      [s,u,k,l] = getblock(a,m-k,n,M);
    else
      n = nnew;
    end
  end
  
  % obtain polynomial q from Laurent coefficients using fft
  N = max(2^nextpow2(length(u)),256);
  ud = polyder(u(end:-1:1)); ud = ud(end:-1:1).';
  ac = fft(conj(fft(ud,N)./fft(u,N)))/N;
  act = zeros(N,1);
  while (norm(1-act(end-n:end-1)./ac(end-n:end-1),inf) > tolfft) && (N < maxnfft),
    act = ac; N = 2*N;
    ac = fft(conj(fft(ud,N)./fft(u,N)))/N;
  end
  ac = real(ac);
  b = ones(1,n+1);
  for j = 1:n,
    b(j+1) = -(b(1:j)*ac(end-j:end-1))/j;
  end
  z = roots(b);
  if any(abs(z)>1), warning('CHEBFUN:cf:ill_conditioned', ...
      ['Ill-conditioning detected. Results may be inaccurate.']);
  end
  z = z(abs(z)<1); rho = 1/max(abs(z)); z = .5*(z+1./z);
  % compute q from the roots for stability reasons
  qt = chebfun(@(x) real(prod(x-z)/prod(-z)),'vectorize');
  q = chebfun; q = define(q,d,qt); % (d should be a domain here).
 
  % compute Chebyshev coeffs of approximation Rt from Laurent coeffs of
  % Blaschke product using fft
  v = u(end:-1:1); N = max(2^nextpow2(length(u)),256);
  ac = fft(exp(2*pi*1i*M*(0:N-1)'/N).*conj(fft(u,N)./fft(v,N)))/N;
  act = zeros(N,1);
  while (norm(1-act(1:m+1)./ac(1:m+1),inf) > tolfft) && ...
      (norm(1-act(end-m+1:end)./ac(end-m+1:end),inf) > tolfft) && (N < maxnfft),
    act = ac; N = 2*N;
    ac = fft(exp(2*pi*1i*M*(0:N-1)'/N).*conj(fft(u,N)./fft(v,N)))/N;
  end
  ac = s*real(ac);
  ct = a(end:-1:end-m) - ac(1:m+1)' - [ac(1), ac(end:-1:end-m+1)'];  
  s = abs(s);
  
  % compute numerator polynomial from Chebyshev expansion of 1./q and Rt
  % we know the exact ellipse of analyticity for 1./q so use this knowledge
  % to obtain its Chebyshev coeffs (see line below)
  gam = chebpoly(chebfun(@(x) 1./feval(q,x),d,ceil(log(4/eps/(rho-1))/log(rho))));
  gam = [zeros(1,2*m+1-length(gam)),gam];
  gam = gam(end:-1:end-2*m); gam(1) = 2*gam(1);
  gam = toeplitz(gam);
  % the following steps reduce the Toeplitz system of size 2*m+1 to a
  % system of size m, and then solve it; if q has zeros close to the
  % domain, then G is ill-conditioned and accuracy is lost
  A = gam(1:m,1:m); B = gam(1:m,m+1);
  C = gam(1:m,end:-1:m+2); G = A+C-2*B*B'/gam(1,1);
  if (cond(G)/s > tolcond) && (cond(G) > tolcondG),
    warning('CHEBFUN:cf:ill_conditioned', ...
      ['Ill-conditioning detected. Results may be inaccurate.']);
  end
  bc = G\(-2*(B*ct(1)/gam(1,1)-ct(m+1:-1:2)'));
  bc0 = (ct(1)-B'*bc)/gam(1,1); bc = [bc0, bc(end:-1:1)'];
  p = chebfun(chebpolyval(bc(end:-1:1)),d);
  r = @(x) feval(p,x)./feval(q,x);
end


function [s,u,k,l,rflag] = getblock(a,m,n,M)
% each hankel matrix corresponds to one diagonal m - n = const in the 
% CF-table; when a diagonal intersects a square block, the eigenvalues
% on the intersection are all equal; k and l tell you how many entries on
% the intersection appear before and after the eigenvalue s under
% consideration; u is the corresponding eigenvector

tol = 1e-14;
if n > M + m + 1,
  c = zeros(1,n-m-M-1); nn = M + m + 1;
else
  c = []; nn = n;
end
c = [c,a(M+1-abs(m-nn+1:M))];
if length(c) > 1024,
  opts.disp = 0; opts.issym = 1; opts.isreal = 1;
  opts.v0 = ones(length(c),1)/length(c);
  [V,D] = eigs(hankel(c),min(n+10,length(c)),'lm',opts);
else
  [V,D] = eig(hankel(c));
end
[S,i] = sort(abs(diag(D)),'descend');
s = D(i(n+1),i(n+1)); u = V(:,i(n+1));
tmp = abs(S - abs(s)) < tol;
k = 0; l = 0;
while (k<n) && tmp(n-k),
  k = k + 1;
end
while ((n+l+2) < length(tmp)) && tmp(n+l+2),
  l = l + 1;
end
if (n+l+2) == length(tmp), rflag = 1; else rflag = 0; end
