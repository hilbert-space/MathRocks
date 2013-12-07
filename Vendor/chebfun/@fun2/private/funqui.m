function [f, dOpt] = funqui(vals, ends, d)
%FUNQUI    Rational interpolant of equispaced data.
%   F = FUNQUI(VALS) constructs a function handle F to a rational interpolant
%   of equispaced data in VALS in the interval specified by ends. It uses
%   Floater-Hormann interpolation with an adaptive choice of their blending 
%   degree d if it is not provided as an input.

n = length(vals) - 1;

if ( n <= 1 )
    f = @(zz) bary(zz,vals,ends(:),[1; -1]);
    return
end

% Limit the maximal d to try depending on n:
if ( n < 60 )
    maxd = min(n, 35);
elseif ( n < 100 )
    maxd = 30;
elseif ( n < 1000 )
    maxd = 25;
elseif ( n < 5000 )
    maxd = 20;
else
    maxd = 15;
end

% Initialise:
errs = zeros(1, min(n, maxd) - 1);
x = linspace(ends(1), ends(2), n+1)';
xrm = x;
rmIndex = [2, n-1];
xrm(rmIndex) = [];
fvalsrm = vals;
fvalsrm(rmIndex) = [];

% Select a d:
if ( norm(vals(rmIndex), inf) < 2*eps*norm(vals, inf) )
    % This case fools funqui, so take a small d:
    dOpt = 4;
elseif (nargin < 3)
    % find a near optimal d
    for d = 0:min(n-2, maxd)
        if ( d <= (n-5)/2 )
            wl = abs( fhBaryWts(xrm, d, d+2) );
            wr = flipud( abs( fhBaryWts(flipud(xrm), d, d+2) ) );
            w = [wl; wl(end)*ones(n-5-2*d, 1); wr];
            w(1:2:end) = -w(1:2:end);
        else
            w = fhBaryWts(xrm, d);
        end
        yyrm = bary(x(rmIndex), fvalsrm, xrm, w);
        errs(d+1) = max( abs( yyrm - vals(rmIndex) ) );
        if ( errs(d+1) > 1000*min(errs(1:d+1)) ) 
            errs(d+2:end) = [];
            break
        end
    end
    % Find the index of the smallest error:
    [ignored, minind] = min(errs);
    dOpt = min(minind) - 1;
elseif (nargin == 3)
    dOpt = d;
end

% Compute FH weights:
if ( dOpt <= (n-1)/2 ) 
    wl = abs( fhBaryWts(x, dOpt, dOpt+1) );
    w = [wl; wl(end)*ones(n-1-2*dOpt, 1); flipud(wl)];
    w(1:2:end) = -w(1:2:end);
else
    w = fhBaryWts(x, dOpt);
end
f = @(zz) bary(zz,vals,x,w);

end

function w = fhBaryWts(x, d, maxind) 
% function for the computation of the FH weights
n = length(x) - 1;
if ( nargin < 3 )
    maxind = n+1;
end
w = zeros(min(n+1, maxind), 1);
for k = 1:min(n+1, maxind)
   for m = k-d:k
      if ( m < 1 || m > n + 1 - d )
         continue
      end
      prod = 1;
      for j = m:m+d
         if ( j ~= k )
            prod = prod/( x(k) - x(j) );
         end
      end
      w(k) = w(k) + (-1)^m*prod;
   end
end
end