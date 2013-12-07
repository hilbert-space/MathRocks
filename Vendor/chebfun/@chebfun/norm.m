function [normA, normLoc] = norm(A,n)
% NORM   Chebfun or quasimatrix norm.
%
% For chebfuns:
%    NORM(f) = sqrt(integral of abs(f)^2).
%    NORM(f,2) is the same as NORM(f).
%    NORM(f,'fro') is also the same as NORM(f).
%    NORM(f,1) = integral of abs(f).
%    NORM(f,inf) = max(abs(f)).
%    NORM(f,-inf) = min(abs(f)).
%
% For quasi-matrices:
%    NORM(A) is the Frobenius norm, sqrt(sum(svd(A).^2)).
%    NORM(A,1) is the maximum of the 1-norms of the columns of A.
%    NORM(A,2) is the largest singular value of A.
%    NORM(A,inf) is the maximum of the 1-norms of the rows of A.
%    NORM(A,'fro') is the same as NORM(A).
%
% Furthermore, the +\-inf norms for chebfuns may also return a second
% input, giving the position where the max/min occurs. For quasimatrices, 
% the 1, inf, and p-norms can return as their 2nd output the index of the 
% column with the largest norm.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin==1, n='fro'; end              % Frobenius norm is the default
                                        % (2 norm would be much slower)
                                        
normLoc = [];

if isempty(A)                           % Empty chebfun has norm 0
    normA = 0;                          
elseif numel(A) == 1                    % A is a chebfun
    switch n
        case 1
            if nargout == 2
                error('CHEBFUN:norm:argout',...
                    'Cannot return two outputs for 1-norms');
            end
            absA = abs(A);
            normA = sum(absA);
        case {2,'fro'}
            if nargout == 2
                error('CHEBFUN:norm:argout',...
                    'Cannot return two outputs for ''fro''-norms');
            end
            if A.trans
                normA = sqrt(abs(A*A'));
            else
                normA = sqrt(abs(A'*A));
            end
        case {inf,'inf'}
            if isreal(A)
                [normA normLoc] = minandmax(A);
                [normA idx] = max([-normA(1), normA(2)]);
                normLoc = normLoc(idx);
            else
                [normA normLoc] = max(conj(A).*A);
                normA = sqrt(normA);
            end
        case {-inf,'-inf'}
            [normA normLoc] = min(abs(A));
        otherwise
            if isnumeric(n) && isreal(n)
                if nargout == 2
                    error('CHEBFUN:norm:argout',...
                        'Cannot return two outputs for p-norms');
                end
%                 normA = sum((conj(A).*A).^(n/2))^(1/n);
                normA = sum(abs(A).^n)^(1/n);
            else
                error('CHEBFUN:norm:unknown','Unknown norm');
            end
    end
else                                    % A is a quasimatrix
    switch n
        case 1
            normA = zeros(numel(A));
            for k = 1:numel(A)
                normA(k) = norm(A(k),1);
            end
            [normA normLoc] = max(norm(A));
        case 2
            if nargout == 2
                error('CHEBFUN:norm:argout',...
                    'Cannot return two outputs for quasimatrix 2-norms');
            end
            s = svd(A,0);
            normA = s(1);
        case 'fro'
            % Find integration dimension: 1 if column, 2 if row
            if nargout == 2
                error('CHEBFUN:norm:argout', ...
                    'Cannot return two outputs for quasimatrix ''fro''-norms');
            end
            dim = 1 + double(A(1).trans);
            normA = sqrt( sum( sum(A.*conj(A),dim) ) );
        case {'inf',inf}
            [normA normLoc] = max(sum(abs(A),2));
        case {'-inf',-inf}
            [normA normLoc] = min(sum(abs(A),2));
        otherwise
            if isnumeric(n) && isreal(n)
%                 normA = max(sum((conj(A).*A).^(n/2)))^(1/n);
%                 normA = max(sum(abs(A).^n))^(1/n);
                [normA normLoc] = max(sum(abs(A).^n));
                normA = normA^(1/n);
            else
                error('CHEBFUN:norm:unknown2','Unknown norm');
            end
    end
end
normA = real(normA);       % discard possible imaginary rounding errors
