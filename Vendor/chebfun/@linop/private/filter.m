function [v cut] = filter(v,thresh)

% The chebfun constructor is happy only when coefficient sizes drop below a
% level that is tied to machine precision. For solutions of BVPs, this is
% unrealistic, as the condition number of the problem creates noise in the
% solution at a higher level. Here we try to detect whether the
% coefficients have reached a "noise plateau" falling below the given 
% relative threshold. If so, we replace the coefficients on the plateau
% with zero in order to nudge the constructor to stop.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

cut = inf;
n = length(v);
if n < 17, return, end

c = cd2cp(v);    % coeffs in ascending degree
ac = abs(c)/min(max(abs(v)),1); % abs and scl relative to size.

% Smooth using a windowed max to overcome symmetry oscillations.
maxac = ac;
for k = 1:8
  maxac = max(maxac(1:end-1),ac(k+1:end));
end

% If too little accuracy has been achieved, do nothing.
t = find(maxac<thresh,1);
if isempty(t) || n-t < 16
  return
end

% Find where improvement in the windowed max seems to stop, by looking at
% the derivative of a smoother form of the curve. 
dmax = diff( conv( [1 1 1 1]/4, log(maxac(t:end)) ) );
mindmax = dmax;
for k = 1:2
  mindmax = min(mindmax(1:end-1),dmax(k+1:end));
end
%cut = t+k+8 + find(mindmax < 0.02*min(mindmax), 1, 'last');
cut = find(mindmax > 0.01*min(mindmax), 3);
if isempty(cut)
    cut = 1;
else
    cut = cut(end) + t + k + 3;
end
c(cut:end) = 0;

% Add a linear function to ensure enpoint values are unchanged.
w = ones(size(c));
w(2:2:end) = -1;
am1 = v(1)-sum(w.*c);
ap1 = v(end)-sum(c);
c1 = 0.5*(ap1+am1);
c2 = 0.5*(ap1-am1);
c([1 2]) = c([1 2]) + [c1 ; c2];

v = cp2cd(c);

end

function p = cd2cp(y)
%CD2CP  Chebyshev discretization to Chebyshev polynomials (by FFT).
%   P = CD2CP(Y) converts a vector of values at the Chebyshev extreme
%   points to the coefficients (ascending order) of the interpolating
%   Chebyshev expansion.  If Y is a matrix, the conversion is done
%   columnwise.

p = zeros(size(y));
if any(size(y)==1), y = y(:); end
N = size(y,1)-1;

yhat = fft([y(N+1:-1:1,:);y(2:N,:)])/(2*N);

p(2:N,:) = 2*yhat(2:N,:);
p([1,N+1],:) = yhat([1,N+1],:);

if isreal(y),  p = real(p);  end

end

function y = cp2cd(p)
%CP2CD   Chebyshev polynomials to Chebyshev discretization (by FFT).
%   CP2CD(P) converts a vector of coefficients of Chebyshev 
%   polynomials to the values of the expansion at the extreme
%   points. If P is a matrix, the conversion is done columnwise.

y = zeros(size(p));
if any(size(p)==1), p = p(:); end
N = size(y,1)-1;

p(2:N,:) = p(2:N,:)/2;
phat = ifft([p(1:N,:);p(N+1:-1:2,:)])*(2*N);

y = phat(N+1:-1:1,:);
if isreal(p),  y = real(y);  end

end
