function B = barymat(M,N,map,w) %BARYMAT(Y,X,W)
% BARYMAT  Barycentric Interpolation Matrix   
%  BARYMAT(Y,X,W), where Y is a vector of length(M) and X and W are vectors
%  of length(N), returns the M*N matrix which interpolates data from the grid 
%  X to the grid Y using barycentric weights W. If W is not supplied it is 
%  assumed to be the Chebyshev weights W(j) = (-1)^j, W([1 N]) = 0.5*W([1 N]).
%
%  The points Y are assumed to lie within the interval [X(1) X(end)].
%
%  BARYMAT(M,N) returns the M*N matrix which interpolates a set of values 
%  on an N-point Chebyshev grid to values on an M-point Chebyshev grid.
% 
%  BARYMAT(M,N,MAP) is the same as the above, but for the mapped Chebyshev 
%  grid defined by the map structure or function handle MAP.
%
%  BARYMAT(M,N,W) or BARYMAT(M,N,MAP,W) is similar, but uses the barycentric 
%  weights given in W, which should be a vector of length N.

%  Copyright 2011 by The University of Oxford and The Chebfun Developers. 
%  See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

warning('off', 'MATLAB:divideByZero'); % TODO: Delete this.

if length(M) == 1 && length(M) == length(N) 
% Size of matrix is given.
    if M == N    % Nothing to do here.
        B = eye(M); 
        return
    else
        if nargin < 4, w = []; end
        if nargin < 3, 
            map = [];          % No map given. Default to Chebyshev.
        elseif isstruct(map)
            map = map.for;     % Extract the forward map from map structure.
        elseif ~isempty(map) && isnumeric(map)
            w = map; map = []; % map is actually the barycentric weights.
        end       
    end
    
    x = chebpts(N);            % The original grid
    y = chebpts(M);            % The up/down-sampled grid
    if ~isempty(map), x = map(x); y = map(y); end % Map the points

elseif isempty(M) || isempty(N) 
% Not much to do here.
    B = []; return, 
else
% Grid points are given.

    x = N; N = length(x);
    y = M; M = length(y);
    if nargin == 3, w = map; else w = []; end
    if M == N && all(x==y)     % Nothing to do here
        B = eye(N); 
        return
    end
    
end
    
if isempty(w) % Default to the Chebyshev barycentric weights
    w = ones(N,1); w(2:2:end) = -1; w([1 N]) = 0.5*w([1 N]);
end

% Construct the matrix
if M >= 500 && N >= 1000         % <-- Experimentally determined.
% Testing shows BSXFUN is faster in this regime    
    B = bsxfun(@minus,y,x');     % Repmat(Y-X')
    B = bsxfun(@rdivide,w',B);   % w(k)/(y(j)-x(k))
    c = 1./sum(B,2);             % Normalisation ('denom' in bary-speak).
    B = bsxfun(@times,B,c);
else    
% Else use for loops
    B = bsxfun(@minus,y,x');     % Repmat(Y-X')
    for k = 1:N
        B(:,k) = w(k)./B(:,k);   % w(k)/(y(j)-x(k))
    end
    c = 1./sum(B,2);             % Normalisation ('denom' in bary-speak).
    for j = 1:M
        B(j,:) = B(j,:)*c(j);
    end
end

% Where points coincide there will be division by zeros (as with bary.m). 
% Replace these entries with the identity.
B(isnan(B)) = 1;








