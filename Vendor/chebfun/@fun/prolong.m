function g = prolong(g,nout)
% This function allows one to manually adjust the number of points.
% The output gout has length(gout) = nout (number of points).

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

n = g.n;
m = nout - n;

% Trivial case
if m == 0
    return
end
% Constant case
if n == 1
    g.vals = g.vals*ones(nout,1);
    g.n = nout;
    g.coeffs = [zeros(nout-1,1) ; g.coeffs(1)];
    return
end

if (m<0 && nout<33 && n<1000)% Use barycentric to prolong
    g.vals = bary(chebpts(nout),g.vals); g.n = nout;
    g.coeffs = chebpoly(g,2,'force');
else % Use FFTs to prolong
    c = chebpoly(g);  
    if m>=0
        % Simple case, add zeros as coeffs.
        c = [zeros(m,1); c];
        g.vals = chebpolyval(c); g.n = nout; g.coeffs = c;
    else
        
%         % Old version of prolong
%         % % To shorten a fun, we need to consider aliasing
%         c = c(end:-1:1);
%         calias = zeros(nout,1);
%         nn = 2*nout-2;
%         calias(1) = sum(c(1:nn:end));        
%         for k = 2:nout-1
%             calias(k) = sum(c(k:nn:end))+sum(c(nn-k+2:nn:end));
%         end
%         calias(nout) = sum(c(nout:nn:end));
%         calias = calias(end:-1:1);
%         g.vals = chebpolyval(calias); g.n = nout; 

        % Reduce to just one coeff?
        c = c(end:-1:1);
        if nout == 1
            g.vals = sum( c(end:-2:1) );
            g.coeffs = g.vals;
            g.n = 1;
        % Otherwise spread the trailing coeffs
        else
            nn = 2*nout - 2;
            for j=nout+1:length(c)
                k = abs( mod( j+nout-3 , nn ) - nout + 2 ) + 1;
                c(k) = c(k) + c(j);
            end
            c = c(nout:-1:1);
            g.vals = chebpolyval(c); g.n = nout; g.coeffs = c;
        end
        
    end
end
