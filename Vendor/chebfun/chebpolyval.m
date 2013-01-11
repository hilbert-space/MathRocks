function v = chebpolyval(c,kind)
%CHEBPOLYVAL   maps Chebyshev coefficients to values at Chebyshev points
%   CHEBPOLYVAL(C) returns the values of the polynomial 
%   P(x) = C(1)T_{N-1}(x)+C(2)T_{N-2}(x)+...+C(N) at 2nd-kind Chebyshev nodes.
%   CHEBPOLYVAL(C,1) returns the values of P at 1st-kind Chebyshev points. 

%   Copyright 2011 by The University of Oxford and The Chebfun Developers. 
%   See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin == 1, kind = 2; end % Default to 2nd-kind points

if isa(c,'chebfun')
    if kind == 2
        v = c.vals; 
    else
        v = zeros(length(c),1);
        idx1 = 0;
        for k = 1:c.nfuns
            idx2 = idx1+c.funs(k).n;
            v(idx1+1:idx2) = chebpolyval(chebpoly(c.funs(k)),1);          
            idx1 = idx2;
        end
    end
    return
end

c = c(:);       % Input should be a column vector
lc = length(c);
if lc == 1, v = c; return; end

if kind == 2    % 2nd kind Chebyshev points
    ii = 2:lc-1;
    c(ii) = 0.5*c(ii);
    v = [c(end:-1:1) ; c(ii)];
    if isreal(c)
        v = real(ifft(v));
    elseif isreal(1i*c)
        v = 1i*real(ifft(imag(v)));
    else
        v = ifft(v);
    end
    v = (lc-1)*[ 2*v(1) ; v(ii)+v(2*lc-ii) ; 2*v(lc) ];
    v = v(end:-1:1);

else            % 1st kind
    if isreal(c)
        v = realvals(c);
    elseif isreal(1i*c)
        v = 1i*realvals(imag(c));
    else
        v = realvals(real(c)) + 1i*realvals(imag(c));
    end
end

function c = realvals(c) % Real case - Chebyshev points of the 1st kind

if ~any(c), return, end  % If all c are 0, there's nothing to do.

c = flipud(c); n = length(c);
w = n*exp(1i*(0:n-1)*pi/(2*n)).';
c = w.*c;
vv = real(ifft(c));
if rem(n,2) == 0 % Even case
    c(1:2:n-1) = vv(1:n/2);
    c(n:-2:2) = vv(n/2+1:n);
else             % Odd case
    c(1:2:n) = vv(1:(n+1)/2);
    c(n-1:-2:2) = vv((n+1)/2+1:n);
end
c = c(end:-1:1);
