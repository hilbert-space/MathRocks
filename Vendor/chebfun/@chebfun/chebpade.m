function [p, q, r_handle] = chebpade(F,m,n,varargin) 
% CHEBPADE    Chebyshev-Pade approximation
%
% [P,Q,R_HANDLE] = CHEBPADE(F,M,N) constructs R_HANDLE = P/Q, where P and
% Q are chebfuns corresponding to the [M/N] Chebyshev-Pade approximation 
% of type Clenshaw-Lord, i.e., the rational function has maximum contact
% with the Chebyshev series of the chebfun F. R_HANDLE is a function handle
% for the rational function. The same functionality is obtained with 
% CHEBPADE(...,'clenshawlord').
%
% CHEBPADE(...,'maehly') Chebyshev-Pade approximation
%   of type Maehly, which satisfies the linear Pade condition. 
%
% CHEBPADE(...,K) uses only the K-th partial sum in Chebyshev expansion 
% of F.
%
% If F is a quasimatrix then so are the outputs P & Q, 
% and R_HANDLE is a cell array of function handles.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin == 2, 
    n = 0; 
    type = 'clenshawlord'; 
    M = -1;
end
if nargin == 3, 
    type = 'clenshawlord';
    if ~isnumeric(n)
        n = 0;
    end
    M = -1;
end
if nargin == 4
    if isnumeric(varargin{1})
        M = varargin{1};
        type = 'clenshawlord';
    elseif ischar(varargin{1})
        M = -1;
        type = varargin{1};
        if ~(strcmpi(type,'clenshawlord') || strcmpi(type,'maehly'))
        error('CHEBFUN:remez:input_parameters',...
            'Unrecognized sequence of input parameters.')
        end
    end
end
if nargin == 5
    if isnumeric(varargin{1}) && ischar(varargin{2})
        M = varargin{1}; type = varargin{2};
    elseif ischar(varargin{1}) && isnumeric(varargin{2})
        type = varargin{1}; M = varargin{2};
    else
        error('CHEBFUN:remez:input_parameters',...
            'Unrecognized sequence of input parameters.')
    end
end

if numel(F) > 1, % Deal with quasimatrices    
    trans = false;
    if get(F,'trans')
        F = F.';        trans = true;
    end

    r_handle = cell(1,numel(F)); p = chebfun; q = chebfun;
    % loop over chebfuns
    for k = 1:numel(F)
        [p(:,k) q(:,k) r_handle{k}] = chebpade(F(:,k),m,n,type);
    end
    if trans
        r_handle = r_handle.'; p = p.'; q = q.';
    end
    return
end

if any(get(F,'exps')), error('CHEBFUN:chebpade:inf',...
        'ChebPade does not currently support functions with nonzero exponents'); end

if  strcmp(type,'clenshawlord')
    l = max(m,n);                                     % temp degree in case m < n
    if M >=0
        F = chebfun(@(x) feval(F,x),F.ends([1 end]),M+1);
    elseif (F.nfuns>1)
        error('CHEBFUN:chebpade:multiple_funs',...
      'For a function with multiple funs, the number of coefficients to be considered should be specified.');
    end
        
    c = fliplr( chebpoly(F) )';                       % Chebyshev coeffs
    if length(F) < m+2*n+1, 
        seed = rng(1);
        c = [c ; eps*randn(m + 2*n+1 - length(F),1)]; % this is more stable than zeros?
        rng(seed)
    end    
    c(1) = 2*c(1);
    top = c(abs([m-n+1:m]) + 1);                      % top row of Hankel system
    bot = c([m:m+n-1]      + 1);                      % bottom row of Hankel system
    rhs = c([m+1:m+n]      + 1);                      % rhs of hankel system
    beta = 1;
    if n > 0,
        beta = flipud( [ -hankel(top,bot)\rhs; 1] ) ; % denominator of Laurent-Pade
    end
    c(1) = c(1)/2;
    alpha = conv( c(1:l+1), beta );                   % numerator of Laurent-Pade
    alpha = alpha(1:l+1);
    beta = beta';
    D = zeros(l+1,l+1);                               % temporary matrix
    D(1:l+1,1:n+1) = alpha(:,ones(n+1,1)).*...
         beta(ones(l+1,1),:);
    pk(1) = sum( diag(D) );
    for k = 1:m
        pk(k+1) = sum( [diag(D,k); diag(D,-k)] );    % numerator of Cheb-Pade
    end
    for k = 1:n+1
        u = beta(1:n+2-k); v = beta(k:end);
        qk(k) = u*v';                                % denominator of Cheb-Pade
    end
    pk = pk/qk(1); qk = 2*qk/qk(1); qk(1) = 1;
    p = chebfun(chebpolyval(fliplr(pk)), F.ends([1 end]) );            % chebfun of numerator
    q = chebfun(chebpolyval(fliplr(qk)), F.ends([1 end]) );            % chebfun of denominator
    r_handle = @(x) feval(p,x)./feval(q,x);   
elseif strcmp(type,'maehly')
    tol = 1e-10; % tolerance for testing singular matrices
    if numel(F) > 1, % Deal with quasimatrices    
        trans = false;
        if get(F,'trans')
            F = F.';        trans = true;
        end

        r_handle = cell(1,numel(F)); p = chebfun; q = chebfun;
        % loop over chebfuns
        for k = 1:numel(F)
            [r_handle{k} p(:,k) q(:,k)] = chebpade(F(:,k),m,n);
        end

        if trans
            r_handle = r_handle.'; p = p.'; q = q.';
        end

        return
    end

    a = chebpoly(F,1).';
    a = a(end:-1:1);
    if length(F) < m+2*n+1, 
        warning('CHEBFUN:chebpade:coeffs', ...
            ['Not enough coefficients given for [',int2str(m),'/',int2str(n),'] approx.', ...])
            ' Assumming remainder are noise.']); 
        seed = rng(1);
        a = [a ; eps*randn(m + 2*n+1 - length(F),1)]; % this is more stable than zeros?
        rng(seed)
    end
    % denominator
    row = (1:n);
    col = (m+1:m+n)';
    D = a(col(:,ones(n,1))+row(ones(n,1),:)+1)+a(abs(col(:,ones(n,1))-row(ones(n,1),:))+1);
    if n > m,  D = D + a(1)*diag(ones(n-m,1),m); end
    if rank(D,tol) < min(size(D)) % test for singularity of matrix
        if m > 1
            [p q r_handle] = chebpade(F,m-1,n,'maehly');
            warning('CHEBFUN:chebpade:singular_goingleft', ...
                ['Singular matrix encountered. Computing [',int2str(m-1),',',int2str(n),'] approximant.'])
        elseif n > 1
            [p q r_handle] = chebpade(F,m,n-1,'maehly');
            warning('CHEBFUN:chebpade:singlar_goingup', ...
                ['Singular matrix encountered. Computing [',int2str(m),',',int2str(n-1),'] approximant.'])
        else
            error('CHEBFUN:chebpade:singlar_fail', ...
                'Singular matrix encountered. [1/1] approximation is not computable.');
        end
        return
    else 
        qk = [1; -D\(2*a(m+2:m+n+1))];
    end
    % numerator
    col = (1:m)';
    B = a(col(:,ones(n,1))+row(ones(m,1),:)+1)+a(abs(col(:,ones(n,1))-row(ones(m,1),:))+1);
    mask = 1:(m+1):min(m,n)*(m+1);
    B(mask) = B(mask) + a(1);
    if m == 1, B = B.'; end
    B = [a(2:n+1).' ;  B];
    if isempty(B)
        pk = qk(1)*a(1:m+1);
    else
        pk = .5*B*qk(2:n+1)+qk(1)*a(1:m+1);
    end
    % p, q and r_handle
    p = chebfun(chebpolyval(flipud(pk)),F.ends([1 end]));
    q = chebfun(chebpolyval(flipud(qk)),F.ends([1 end]));
    r_handle = @(x) feval(p,x)./feval(q,x);
else 
    error('CHEBFUN:chebpade:type','Unrecognized ChebPade type.');
end
