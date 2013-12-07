function [x, w, v] = lobpts(n, varargin)
%LOBPTS  Gauss-Legendre-Lobatto Quadrature Nodes and Weights.
%  LOBPTS(N) returns N Legendre-Lobatto points X in (-1,1).
%
%  [X,W] = LOBPTS(N) returns also a row vector W of weights for
%  Gauss-Legendre-Lobatto quadrature.
%
%  [X,W,V] = LOBPTS(N) returns additionally a column vector V of weights in
%  the barycentric formula corresponding to the points X. The weights are
%  scaled so that max(abs(V)) = 1.
%
%  [X,W] = LOBPTS(N,METHOD) allows the user to select which method to use.
%    METHOD = 'REC' uses the recurrence relation for the Legendre 
%       polynomials and their derivatives to perform Newton iteration 
%       on the WKB approximation to the roots. Default for N < 100.
%    METHOD = 'ASY' uses the Hale-Townsend fast algorithm based up
%       asymptotic formulae, which is fast and accurate. Default for 
%       N >= 100.
%    METHOD = 'GLR' uses the Glaser-Liu-Rokhlin fast algorithm [2], which
%       is fast and can give better relative accuracy for the -.5<x<.5
%       than 'ASY' (although the accuracy of the weights is usually worse).
%    METHOD = 'GW' will use the traditional Golub-Welsch eigenvalue method, 
%       which is maintained mostly for historical reasons.
%
%  See also chebpts, legpts, jacpts, legpoly, radaupts.

%% Trivial case:
if ( n == 1 )
    error('CHEBFUN:lobpts', 'N = 1 is not supported.');
elseif ( n ==2 )
    x = [-1 ; 1];
    w = [1, 1];
    v = [-1 ; 1];
    return
end

%% Nodes
[x, w, v] = jacpts(n-2, 1, 1, varargin{:});
x = [-1 ; x ; 1];

%% Quadrature weights
w = [-1, w,  1];
w = w./(1-x.^2).';
w([1 end]) = 2/(n*(n-1));

%% Barycentric weights
v = v./(1-x(2:n-1).^2);
v = v/max(abs(v));
if ( n == 3 )
    v1 = -.5;
    sgn = 1;
elseif ( mod(n, 2) )
    v1 = -abs(sum(v.*x(2:end-1).^2)/2);
    sgn = 1;
else
    v1 = -abs(sum(v.*x(2:end-1))/2);
    sgn = -1;
end

v = [v1 ; v ; sgn*v1];

end

