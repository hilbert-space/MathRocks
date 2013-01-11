function out = cov(F,G)
% COV   Covariance.
% 
% COV(F) returns the covariance matrix of the quasi-matrix F. 
% COV(F) is the same as VAR(F) if F is a single chebfun.
% COV(F,G) returns the covariance matrix of the columns of F and G.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% COV(F) is the same as VAR(F) if F is a single chebfun.
if nargin == 1 && numel(F) == 1, out = var(F); return, end

if nargin == 3, error('CHEBFUN:cov:nargin', ...
        'Chebfun/cov does not support normalization.');
end

if nargin == 2 && ~all(size(F)==size(G))
    error('CHEBFUN:cov:size','Quasimatrix dimensions do not agree.');
end

if nargin == 1
    if F(1).trans
        out = transpose(cov(transpose(F)));
    else
        out = zeros(numel(F));
        Y = 0*F;
        for k = 1:numel(F)
            Y(:,k) = F(:,k)-mean(F(:,k));
        end
        for j = 1:numel(F)
            out(j,j) = mean(Y(:,j).*conj(Y(:,j)));
            for k = j+1:numel(F)
                out(j,k) = mean(Y(:,j).*conj(Y(:,k)));
                out(k,j) = conj(out(j,k));
            end
        end
    end
else
    if F(1).trans
        out = transpose(cov(transpose(F),transpose(G)));
    else
        out = zeros(numel(F));
        Y = 0*F; Z = Y;
        for k = 1:numel(F)
            Y(:,k) = F(:,k)-mean(F(:,k));
            Z(:,k) = G(:,k)-mean(G(:,k));
        end
        for j = 1:numel(F)
            for k = 1:numel(F)
                out(j,k) = mean(Y(:,j).*conj(Z(:,k)));
            end
        end
    end
    
end

