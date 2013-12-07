function out = chebpoly(g,kind,flag)
% CHEBPOLY   Chebyshev polynomial coefficients.
% A = CHEBPOLY(F) returns the coefficients such that
% F = A(1) T_N(x) + ... + A(N) T_1(x) + A(N+1) T_0(x) where T_N(x) denotes 
% the N-th Chebyshev polynomial.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if g.n == 1, out = g.vals; return, end

if nargin == 1 || isempty(kind), kind = 2; end % 2nd kind is the default!
    
if nargin < 3 && ~isempty(g.coeffs) && kind == 2
    out = g.coeffs; 
    % chebpoly should always return a column vector
    %out = out(:); 
    return
end

if kind == 2 % For values from Chebyshev points of the 2nd kind (default)
    n = g.n;
    gvals = g.vals;
    out = [gvals(end:-1:2) ; gvals(1:end-1)];
    if isreal(gvals)
        out = fft(out)/(2*n-2);
        out = real(out);
    elseif isreal(1i*gvals)
        out = fft(imag(out))/(2*n-2);
        out = 1i*real(out);
    else
        out = fft(out)/(2*n-2);
    end
    out = out(n:-1:1);
    if (n > 2), out(2:end-1) = 2*out(2:end-1); end
else        % For values from Chebyshev points of the 1st kind
    gvals = g.vals(end:-1:1);
    if isreal(gvals)
        out = realcoefs(gvals);
    elseif isreal(1i*gvals)
        out = 1i*realcoefs(imag(gvals));
    else
        out = realcoefs(real(gvals))+1i*realcoefs(imag(gvals));
    end
end

% chebpoly should always return a column vector
out = out(:); 

function c = realcoefs(v) % Real case - Chebyshev points of the 1st kind
n = length(v);
w = (2/n)*exp(-1i*(0:n-1)*pi/(2*n)).';
if rem(n,2) == 0 % Even case
    vv = [v(1:2:n-1); v(n:-2:2)];
else             % Odd case
    vv = [v(1:2:n); v(n-1:-2:2)];
end
c = real(w.*fft(vv));
c = c(end:-1:1);
c(end) = 0.5*c(end);
